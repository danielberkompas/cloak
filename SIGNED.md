##### Signed by https://keybase.io/dberkom
```
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQIcBAABCgAGBQJWcOIEAAoJEKU82t1CbYQMtuoP/0S9xdq3tgqInH1WW5qdnsNq
96ltGD5RBb5kXNQ8WqUKfPDhsLaL8KUzk9WNniUo/5NGaig0Eq2N0xhF7ETsuXfP
k10TkrOYGb/dOpMf0sDP5zhkL8cNuG1uGq3IQvsDeR1BzVrNa9JgdNGtnGsYJlod
TriqjU+PJW6l1YvD0ye1ercBN235BdDM9gynqh9PLOIByAmKYUc4H1/Jp8HO9xXr
aeRgl8vPRMfFuxKdZ1SfgwDZCZHa5IKzAa0NRDIXgqYm/5vzG5Vr68pFP23rATAM
woCiZC0IEdyUKUZrD9aDc3azjtUYV1m3CRsLKnV08rKSymu0i86tZxWIIVk6+D0P
1TvuCrwW4+Wu1z5qojnhnF66fbx6FxEPxfQBdAJTp2G2Xnxawa2p1TTw309P+DXt
rhhEddCjFL7Sx8mbPzwDijMjrOvwlHVlM2515EJOIs2/hVUBTRTK5xa3pIltKDh0
XPRV58GTvNN//EfO3ln1Nd24cOunS10JRjkUTt3zyIHygG6PL3dU+CikrF4c84Tb
QSIBoJAvWK0TLQtjjJRwrxzBIaVrmLmXIfUN5e36UhZVpvQ3bIkK/+yCa00NC5V2
JCXKWL2/IJ9H3z7sTBAVC9Rzl1Jb4FTyfOhDpIupIOrKzf5Oi3BG1V3u/dk7Mjk/
E9GDRO1kGfXibwrW4tNM
=/7XJ
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size  exec  file                              contents                                                        
            ./                                                                                                
1009          CHANGELOG.md                    9d1fc2f704bcb3020fbea726ea1eee0358b082b24c54da18952840657044f148
1083          LICENSE                         19d19056f1f4578cedeb79241715a815a61b0f06793f4e779544c45c8df232c2
1669          README.md                       2ee77c8c517ff829f0df9b64150e175d30a2a0a051bf5394a267444c986a5eaf
              lib/                                                                                            
                cloak/                                                                                        
                  ciphers/                                                                                    
5432                aes_ctr.ex                d278a8013de9b281f506d7ced23f874d2ed6cc30797ddb4784fcf3312484520e
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
954           mix.exs                         d1e3c218f2339df74d280db51d9f8f769d9d09a1cd0eb3ee6fe34b6a55f18327
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