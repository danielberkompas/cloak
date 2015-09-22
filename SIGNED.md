##### Signed by https://keybase.io/dberkom
```
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQIcBAABCgAGBQJWAc0wAAoJEKU82t1CbYQMPN4QAJL52qn7vnocmFwkV8SGtzjo
euyZa9pgbwYliTioD6RwafjwHqiqp7TQMI6JfMsqbXWH0ViGu6ipaEYMt/ZGhKAb
KbQdaUpcdho90cSkdeXtNX2A57mK44sRmoB9hosQ6ULpZ+dpFdYuEz40qLdpC6Gj
91Mcz5ZO6Ji1u+e077vlgsan7r7pLOK4N0EueA34rKt34bIQEF0hg+6gMEhGhhbE
zhHheaOdCHcWmVsUMBdquQE0+uTDAJNR4AMP9nCkATIVClJjd5rcHI4OLASlhbbX
rM1VDgtjztST0ag8CHF3aQZ+qCgfn9RCJLPVFDrdwMupOaTqwzE343sgzjxTpkgM
2UWFJm+nixSoNFw674BJOYBCkn0hufEMw8URsEFOeRemuLUykYPDHINp+jBBDCnt
Cxwm85QZESvtHXc0DqgrqN0HCoF7sCwRQtbyyd3/W4LPH30aXedbpk5+005GvWew
DNpwrSHzT2CKRlBLGD7SWcfeaF5XVLgrCi/mnt9F6fp4IJhR5dtMm0VCDnObcOfo
ZT88+rMvkf8/Bm8TOvtBzjpK9A8ZJhS4TBKpUnF9cACtUfYL00Xi0Qn4fpKlcjGc
4M6k1GlQYiHcnk0g3KPuJCGYUd2R8xTSXbOMER9lsPJ++fqknMEUElulE+6sELPp
EWTQ7vbsAMq1dP9K3oJY
=6xbg
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size  exec  file                              contents                                                        
            ./                                                                                                
240           CHANGELOG.md                    c80ed7ae07436b3588428c5b1aa446bb43a837d01a3367f46667b03ae9f7db65
1023          README.md                       1729f6833386b94e2faec3d3db132a1936d00a56ac9964875f4d46cbcd4955c7
              lib/                                                                                            
                cloak/                                                                                        
                  ciphers/                                                                                    
4716                aes_ctr.ex                feb9314429df52e66c6ff0c2d3bac76857828d26047cfa21386c4d8770c37516
2175                behaviour.ex              5669a4679fc5e9f82a793f052062ba94cb08d27d23c03d271ad4b1ef897a08dd
469               config.ex                   ce487149f713557272ed46e27f7b8316a7aa6ef738637b155b0811bdddb29ea5
1299              model.ex                    07e760087e90bd1625d3e9fbbd40d7db45dab51d243e65a815b17fafe4a1ecfb
5673            cloak.ex                      21c67d8dedb369a215015019050519aa068e354cb8ffcadbfe47497ac6e84ab3
                ecto/                                                                                         
240               encrypted_binary_field.ex   9eb70e95d76f15cc3e5f1d349af1b8a3056d7ad14abf5673610cbb907c652ddd
783               encrypted_field.ex          913647162739133656db5ae815ab8b086480ae20e73e91e1ec17a691c529c190
403               encrypted_float_field.ex    d582d797c9495322b84a2bf222e88523ac233ac9903eff564809f8f75b5b4ce2
413               encrypted_integer_field.ex  4233cdb3a49630209c37bffd2c124c2716941d4b58d785c068eaa1a08893c433
837               encrypted_map_field.ex      e57df1cac3dd53dedffb8212005f31dce1dfd1888285330c348b2aa1a92ae4d9
1411              sha_256_field.ex            31772c23b80cadbab42e3bda86ed4e9915e6593e328230c3b89da088418c9828
                mix/                                                                                          
                  tasks/                                                                                      
2820                cloak.migrate.ex          3a4bb04b29d1add671f886b37502c1cdceb4be3d97611f3ef8af0eef2299790e
922           mix.exs                         5c9f501ab9cd673ea3f358dfa7cb86ab3b33fa9f53e943c0477d3b513a199434
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