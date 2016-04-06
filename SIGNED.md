##### Signed by https://keybase.io/dberkom
```
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQIcBAABCgAGBQJXBSplAAoJEKU82t1CbYQMOGUP/j5OSMxZ0RGCbs3rsK2+g0GV
Ief4X/T7lqc3n/k1AyozAQMdaduPh2pGqJ1zsCanIOQj8Sn/hq/7o6DWjpTapz5u
S2pRB25LKkLQFrsCjV8xJyhAVCw/+/qkJdtbIcs6CThHKpzXU1koefBrL7sRhiWo
GG23ZVrFt5U/wTQQGXuHAgg+Dr0UNgZqRPOrA4YIvHfpE1YfvD5u1+QkxjvX23vH
DqXU7ve+KATZSpJcKC4orbjw8noGbXRAPdl7Rwq0TygKijO47RD9czPei9o1MW8Q
mhuXqN3Gn7jCg7yRk2zls56JB7abAUG+xKufP2h6Eby9O+qJ02QYklnBaRAEWssv
MTDCP6rkwlCS0beR390xS9NBdamXKmEqUXyg/LN2+45m1HJU95se712EdN6f79kM
wOQnIoCIkAOD1eF0DUY1KeYjrZP89MA+E8LG+uQiL02zORoaRsfeJASM5PwVttcF
BRFSAHLTgwCQXK4GX/ccH8wHpxisPPUmOommF3OTfGC/E8KN1Lxvfi3lv2FujjEC
YjbBXU+4kacRnfHjn9KP3sEyvPirdrV35Lgqd9gY0E+kRp8qf1M5xdQaGrO+aJmz
nb9L/gneX8OmujeOM9VBSuibXzXtq8QhRLSGaqL/umgRikvDzujlsnSOaQz8s6mC
Q45NuteP3W7j610YcCq9
=rFWy
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size  exec  file                              contents                                                        
            ./                                                                                                
1350          CHANGELOG.md                    4088516045ba55f67ecdb00b0361e3cfa1e86b9f094703ce7abede4ed440313e
              lib/                                                                                            
                cloak/                                                                                        
                  ciphers/                                                                                    
5432                aes_ctr.ex                d278a8013de9b281f506d7ced23f874d2ed6cc30797ddb4784fcf3312484520e
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
954           mix.exs                         6f3a104f47c5f300ee9d5fcf39353576f25ab6ad77b315d6883fb51d05325754
1806          README.md                       a175800acb386384bd08487d9b1bebc188f024442e6da79630c649fb4df82b30
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