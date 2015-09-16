##### Signed by https://keybase.io/dberkom
```
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQIcBAABCgAGBQJV+fk8AAoJEKU82t1CbYQMs4oQAKIWEIrokLPXkKuoKKvMcKtp
yrFVtSPvOP3JL2R4Q+5WKg81McfEvSBCuoeDkgL3+TByCQDGPhDsD6crH7g85NQh
ZSqdT4yzw1xtYjxdMHsFYYT15h7gWvGpEQwWKDwCc7pxZHI0nIQxryQS19Bh8Ocj
riCvqE6EYqc6MvX040ZJkTQa9TFcFNLO+U2o25MqHXC7vUvGL+vufFiUw6WIZOjb
shaqCekQFvOJFAZNs7oh8O6rIXNSIuvNVHdeD8TR+74JPzZJAj5DNXCZaghDGmKq
azXNFV8bhcoYx++05r39VhLhBL9FUro2Dz0XMUtuZ76bqJP2xk7EnLYmxV8PB1i2
hpKXPon2caZ7UY343V7Wg5bEQYqXGH9iNsA9b8lNakoHLVl4D7FmFrfxMnyMHJyL
lcwUk2h4QuHu5BNIffkVFEE0WMail4fEXABwsfb8amTa3L4akEH4onPegCWpMHZC
xC93qBtu0+LWRZkIU6HIbGlte5on6TwlDLaUFVZ8fKE7LjZwBJVWaW1COO3XennQ
04vauBbIRPQ4OHFD6pEovlDiIMMGX/SdSj9JKjLM6BWxS0AQ+g8xfZPqi05lRHst
UwsfmPJpZxrT+aG7lbDCDvdWHxN+iPh0G/To9LNh916xyyVh+o3wJDowGv2BuKJd
NTcoGDpLNBcI4IVvfQnk
=nix4
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size  exec  file                              contents                                                        
            ./                                                                                                
153           CHANGELOG.md                    42e628018fccb4a446a68c506c2e9437df5eb0ab0071c89cf4248f2dc3a398d6
242           README.md                       d113a976523d5c69acada09a9e751af82b5cba664334043ae96a41c96290d934
              lib/                                                                                            
                cloak/                                                                                        
                  ciphers/                                                                                    
4126                aes_ctr.ex                fd04e11042fb4ae288c20971e71f2d2918b1324b8b3483c212e9491695537d4e
764                 behaviour.ex              834bd9d829e3ca079ce711c58a453090314e9c6fd2b8e2a70f15d2e81077d06d
430               config.ex                   e6c59799222806913b39ac5ce9c171860f4a8f568501b9cb35ed141da58bee5d
1222              model.ex                    fb20b7d9a7ad3a549ac0eaf649bcf6ec9b70b00fa7c464d409b2fb60567e6a11
4271            cloak.ex                      dbdafa7706514cb358151841372c571946951e1ca93bb4c1256df9a6c9e5b2f3
                ecto/                                                                                         
240               encrypted_binary_field.ex   9eb70e95d76f15cc3e5f1d349af1b8a3056d7ad14abf5673610cbb907c652ddd
783               encrypted_field.ex          913647162739133656db5ae815ab8b086480ae20e73e91e1ec17a691c529c190
403               encrypted_float_field.ex    d582d797c9495322b84a2bf222e88523ac233ac9903eff564809f8f75b5b4ce2
413               encrypted_integer_field.ex  4233cdb3a49630209c37bffd2c124c2716941d4b58d785c068eaa1a08893c433
837               encrypted_map_field.ex      e57df1cac3dd53dedffb8212005f31dce1dfd1888285330c348b2aa1a92ae4d9
1411              sha_256_field.ex            31772c23b80cadbab42e3bda86ed4e9915e6593e328230c3b89da088418c9828
896           mix.exs                         e8931ed2c79724fe54fea21a178e5b352b2f4f095cd24d4c6832b21279b842e3
```

#### Ignore

```
/SIGNED.md
```

#### Presets

```
git      # ignore .git and anything as described by .gitignore files
dropbox  # ignore .dropbox-cache and other Dropbox-related files    
kb       # ignore anything as described by .kbignore files          
```

<!-- summarize version = 0.0.9 -->

### End signed statement

<hr>

#### Notes

With keybase you can sign any directory's contents, whether it's a git repo,
source code distribution, or a personal documents folder. It aims to replace the drudgery of:

  1. comparing a zipped file to a detached statement
  2. downloading a public key
  3. confirming it is in fact the author's by reviewing public statements they've made, using it

All in one simple command:

```bash
keybase dir verify
```

There are lots of options, including assertions for automating your checks.

For more info, check out https://keybase.io/docs/command_line/code_signing