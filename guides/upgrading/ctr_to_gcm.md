# How To Migrate From AES.CTR To AES.GCM

`Cloak.Ciphers.AES.CTR` encrypts data without authenticating it, so anyone with
write access to your encrypted data can XOR the stored ciphertext and change what
`decrypt/2` returns, without knowing the key. Because CTR is a stream cipher, the
modification goes unnoticed and your application receives the forged value.
See [CVE-2026-95105](https://cna.erlef.org/cves/CVE-2026-95105.html).

`Cloak.Ciphers.AES.GCM` authenticates the ciphertexts it produces, so modified
data is rejected instead of decrypted. This guide moves your data over to it.

> #### You can reuse your key {: .tip}
>
> AES-256-GCM uses the same 32-byte key as AES-256-CTR. Rotating the key at the
> same time is a good idea, but it is not required to complete this migration.

## Before You Start

Find anything that selects the CTR cipher explicitly, instead of relying on the
vault's default. Those call sites keep producing unauthenticated ciphertext until
they are updated:

- `MyApp.Vault.encrypt(value, :aes_ctr)` calls
- `label: :aes_ctr` on `Cloak.Ecto` types, e.g.
  `use Cloak.Ecto.Binary, vault: MyApp.Vault, label: :aes_ctr`

## 1. Add AES.GCM To Your Vault

Configure `Cloak.Ciphers.AES.GCM` as the first cipher in your vault, and demote
`Cloak.Ciphers.AES.CTR` to a cipher that is only used for decryption.

    config :my_app, MyApp.Vault,
      ciphers: [
        default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: <<...>>, iv_length: 12},
        retired: {Cloak.Ciphers.AES.CTR, tag: "AES.CTR.V1", key: <<...>>}
      ]

> #### Labels don't matter, order does {: .tip}
>
> The `:ciphers` configuration is _order-dependent_. The first cipher in the list
> is used to encrypt all new data, regardless of its label, and every cipher in
> the list is tried when decrypting. The `:default` and `:retired` labels are only
> there for clarity.

Cloak now encrypts new data with AES.GCM, while ciphertext in the CTR format is
still decrypted. If you are also rotating to a new key, the
[Rotate Keys](https://hexdocs.pm/cloak_ecto/rotate_keys.html) guide covers that
part.

## 2. Re-encrypt Your Existing Data

With `cloak_ecto`, the `cloak.migrate.ecto` task re-encrypts every row of a schema
in place, using the vault's default cipher:

    mix cloak.migrate.ecto -r MyApp.Repo -s MyApp.Schema

Run it for each schema that uses your vault. You can also configure
`cloak_repo` and `cloak_schemas` in `config/config.exs` and run it for all of them
at once.

For data that is not in Ecto, decrypt and re-encrypt it yourself, then store the
result:

    value
    |> MyApp.Vault.decrypt!()
    |> MyApp.Vault.encrypt!()

Data also gets converted as it is written, so values that are updated before you
run the migration task will be stored in the GCM format. The task just makes sure
that nothing is left behind.

## 3. Remove AES.CTR

Once you are confident that all of the data has been re-encrypted, remove
`Cloak.Ciphers.AES.CTR` and `Cloak.Ciphers.Deprecated.AES.CTR` from the `:ciphers`
list. From then on Cloak refuses to decrypt CTR ciphertext with a
`Cloak.MissingCipher` error, instead of handing an unauthenticated plaintext to
your application.

> #### Remove it last {: .warning}
>
> Ciphertext in the CTR format cannot be decrypted once the cipher is gone. If you
> remove it too early, the affected values can only be recovered by restoring them
> from a backup or by putting the cipher back.
