##### Signed by https://keybase.io/dberkom
```
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQIcBAABCgAGBQJXPzBkAAoJEKU82t1CbYQMsJUP/2mwyLMkXv8/P5Rs9ZkGS9Z4
JohJueKH1owIQsKEyLrBr3EJgUsqXFQn28Jawo9J/zVuWWVxxu2IapQXh0onhgXY
He3eUZSdANsIcvtfnkJ4bCF9h/vsOGw33E5l6mx6EnWexZHeAUfCPzDRPXGL9UEE
kZwIpmE5td3UMCIgWu7QQF+mwuHSaqRzZPGtJ/ce631eIytA+zObXtQSQDXuFvlA
Pte3qivETByJlo61FJmPRVnWC6tirQBwGfNwkkRSeECw03eXuY7+yalIfJrbNRGm
kCXIk/zO8rbYmW1XxYJUc4DQKv1HF3XKiN6Sc+ZpVyZki84IWxCp+Y6oAh1bQTbZ
fD6lVdayQbr6FfbpQ44IoNReWipwDwRFKqbdVzP6yfW4+c+rxn75eWZ/AR11T5lo
BuLwpPXIB9M8Q79awkQXUNGRfRWXdBd+kcnCNnRCuVh4l71Y20iXQES0OAGK9kdV
uTLAZEhteMFSJXHP29jPIqNSCznfwv4SJ6JQ18juaGNBL7Wg4SYEiAudCGOEqOpV
lWxCZLq5KgNMGrhLKlrg0LOGjcPRu8fvbsPp3daWkBJItQh8aPt9RkZ03U7hNGnQ
wStLGgBIzio4LJE7WdLcoY87s3Qz9iIqCNoW26kuGXniwSUsfTmZ9aZvHRFozc0z
to0imsQoIA0vEtlnU+RC
=UXaB
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size  exec  file                              contents                                                        
            ./                                                                                                
2133          CHANGELOG.md                    8f9ba95637a0082d7ecec60818a50e7c6c8504de8bd17d62a7f4ee09189c0e5d
              lib/                                                                                            
                cloak/                                                                                        
                  ciphers/                                                                                    
5869                aes_ctr.ex                2bcfc24b483d82608755535e5a553dffc4e5626802e0a5460d39371400e0fac0
2126                behaviour.ex              0e397a4c8431ec71ba71d672c605e761f937c58fe1b77c50dce8cbfae6efa3d1
469               config.ex                   ce487149f713557272ed46e27f7b8316a7aa6ef738637b155b0811bdddb29ea5
5646            cloak.ex                      4669f31a7f8e27a0eb604d7c737a0b2decadf5a66b5493f9b366a74a5f7fe61c
                ecto/                                                                                         
240               encrypted_binary_field.ex   9eb70e95d76f15cc3e5f1d349af1b8a3056d7ad14abf5673610cbb907c652ddd
783               encrypted_field.ex          913647162739133656db5ae815ab8b086480ae20e73e91e1ec17a691c529c190
403               encrypted_float_field.ex    d582d797c9495322b84a2bf222e88523ac233ac9903eff564809f8f75b5b4ce2
413               encrypted_integer_field.ex  4233cdb3a49630209c37bffd2c124c2716941d4b58d785c068eaa1a08893c433
837               encrypted_map_field.ex      e57df1cac3dd53dedffb8212005f31dce1dfd1888285330c348b2aa1a92ae4d9
1411              sha_256_field.ex            31772c23b80cadbab42e3bda86ed4e9915e6593e328230c3b89da088418c9828
                mix/                                                                                          
                  tasks/                                                                                      
3710                cloak.migrate.ex          14f7c40b2ae8be639f0ecf17ca565cd005f1199cbb4853faa414fe6623af2c3b
1083          LICENSE                         19d19056f1f4578cedeb79241715a815a61b0f06793f4e779544c45c8df232c2
954           mix.exs                         a8754ca5a27e859b12f2786978f500a7c417321b747c3aabba3cb0dede44ede6
1806          README.md                       b6e3ded7466af4b7f2acf8d31c5f02b9668b01be603840cfd5a0b7ae9b43154d
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