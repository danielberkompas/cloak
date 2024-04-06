# Changelog

## [v1.1.4](https://github.com/danielberkompas/cloak/tree/v1.1.4) (2024-04-06)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v1.1.3...v1.1.4)

**Fixed bugs:**

- ETS error when running Vault without mix [\#125](https://github.com/danielberkompas/cloak/issues/125)

**Merged pull requests:**

- Raise helpful error if vault hasn't been started [\#126](https://github.com/danielberkompas/cloak/pull/126) ([danielberkompas](https://github.com/danielberkompas))

## [v1.1.3](https://github.com/danielberkompas/cloak/tree/v1.1.3) (2024-04-06)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v1.1.2...v1.1.3)

**Fixed bugs:**

- Clock with changeset issue  [\#115](https://github.com/danielberkompas/cloak/issues/115)
- {:badarg, {'aead.c', 90}, 'Unknown cipher or invalid key size'} [\#113](https://github.com/danielberkompas/cloak/issues/113)

**Closed issues:**

- How to use Cloak in ecto queries? [\#122](https://github.com/danielberkompas/cloak/issues/122)
- \(UndefinedFunctionError\) function :crypto.stream\_init/3 is undefined or private [\#118](https://github.com/danielberkompas/cloak/issues/118)

**Merged pull requests:**

- Fix build on SemaphoreCI [\#124](https://github.com/danielberkompas/cloak/pull/124) ([danielberkompas](https://github.com/danielberkompas))
- Allow vault gen server to return other responses [\#123](https://github.com/danielberkompas/cloak/pull/123) ([spencerdcarlson](https://github.com/spencerdcarlson))
- Update cheatsheet to fix mix config [\#121](https://github.com/danielberkompas/cloak/pull/121) ([gworkman](https://github.com/gworkman))
- Misc doc changes [\#110](https://github.com/danielberkompas/cloak/pull/110) ([kianmeng](https://github.com/kianmeng))
- Fix example code for Base.decode64! [\#109](https://github.com/danielberkompas/cloak/pull/109) ([blunckr](https://github.com/blunckr))

## [v1.1.2](https://github.com/danielberkompas/cloak/tree/v1.1.2) (2022-06-17)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v1.1.1...v1.1.2)

**Closed issues:**

- Accepting function as `key` configuration [\#112](https://github.com/danielberkompas/cloak/issues/112)
- ETS problem with Clock as application in umbrella project [\#111](https://github.com/danielberkompas/cloak/issues/111)
- Cloak relies in deprecated :crypto API that will be removed in OTP 24 [\#102](https://github.com/danielberkompas/cloak/issues/102)

**Merged pull requests:**

- Run tests against Elixir 1.13 [\#116](https://github.com/danielberkompas/cloak/pull/116) ([danielberkompas](https://github.com/danielberkompas))

## [v1.1.1](https://github.com/danielberkompas/cloak/tree/v1.1.1) (2021-06-05)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v1.1.0...v1.1.1)

**Merged pull requests:**

- Remove unused pbkdf2 dependency [\#107](https://github.com/danielberkompas/cloak/pull/107) ([danielberkompas](https://github.com/danielberkompas))

## [v1.1.0](https://github.com/danielberkompas/cloak/tree/v1.1.0) (2021-06-05)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v1.0.3...v1.1.0)

**Merged pull requests:**

- Prepare for 1.1.0 release [\#106](https://github.com/danielberkompas/cloak/pull/106) ([danielberkompas](https://github.com/danielberkompas))
- Add regression tests to prepare for OTP 24 [\#105](https://github.com/danielberkompas/cloak/pull/105) ([danielberkompas](https://github.com/danielberkompas))
- Erlang 24 Support [\#104](https://github.com/danielberkompas/cloak/pull/104) ([mjquinlan2000](https://github.com/mjquinlan2000))
- Update Upgrade Documentation Link [\#101](https://github.com/danielberkompas/cloak/pull/101) ([kevin-j-m](https://github.com/kevin-j-m))

## [v1.0.3](https://github.com/danielberkompas/cloak/tree/v1.0.3) (2020-10-20)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v1.0.2...v1.0.3)

## [v1.0.2](https://github.com/danielberkompas/cloak/tree/v1.0.2) (2020-02-01)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v1.0.1...v1.0.2)

**Closed issues:**

- AES GCM should use a 12 byte nonce instead of 16 [\#93](https://github.com/danielberkompas/cloak/issues/93)

**Merged pull requests:**

- \[\#93\] Add option to specify iv length for AES.GCM [\#95](https://github.com/danielberkompas/cloak/pull/95) ([danielberkompas](https://github.com/danielberkompas))

## [v1.0.1](https://github.com/danielberkompas/cloak/tree/v1.0.1) (2020-01-29)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v1.0.0...v1.0.1)

**Closed issues:**

- MyApp.Vault.encrypt\("plaintext"\) failing [\#92](https://github.com/danielberkompas/cloak/issues/92)

**Merged pull requests:**

- Clean up and update dev deps [\#94](https://github.com/danielberkompas/cloak/pull/94) ([chulkilee](https://github.com/chulkilee))

## [v1.0.0](https://github.com/danielberkompas/cloak/tree/v1.0.0) (2019-07-31)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v1.0.0-alpha.0...v1.0.0)

**Closed issues:**

- Outstanding work for 1.0? [\#91](https://github.com/danielberkompas/cloak/issues/91)

**Merged pull requests:**

- Correct code example on upgrading guide [\#90](https://github.com/danielberkompas/cloak/pull/90) ([ruan-brandao](https://github.com/ruan-brandao))

## [v1.0.0-alpha.0](https://github.com/danielberkompas/cloak/tree/v1.0.0-alpha.0) (2018-12-31)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.9.2...v1.0.0-alpha.0)

**Breaking changes:**

- Extract Ecto components to cloak\_ecto hex package [\#77](https://github.com/danielberkompas/cloak/issues/77)

**Merged pull requests:**

- Extract Ecto components to cloak\_ecto [\#89](https://github.com/danielberkompas/cloak/pull/89) ([danielberkompas](https://github.com/danielberkompas))

## [v0.9.2](https://github.com/danielberkompas/cloak/tree/v0.9.2) (2018-12-26)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.9.1...v0.9.2)

**Merged pull requests:**

- Fix typo & add better error msg for PBKDF2 algorithm [\#88](https://github.com/danielberkompas/cloak/pull/88) ([jc00ke](https://github.com/jc00ke))
- Improve PBKDF2 config error messages [\#87](https://github.com/danielberkompas/cloak/pull/87) ([jc00ke](https://github.com/jc00ke))

## [v0.9.1](https://github.com/danielberkompas/cloak/tree/v0.9.1) (2018-10-07)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.9.0...v0.9.1)

**Closed issues:**

- Testing with hashed fields fails to equal fixture [\#85](https://github.com/danielberkompas/cloak/issues/85)
- Migrator Embedded Schema Error [\#81](https://github.com/danielberkompas/cloak/issues/81)

**Merged pull requests:**

- \[\#81\] Fix migrator with embedded schemas [\#83](https://github.com/danielberkompas/cloak/pull/83) ([danielberkompas](https://github.com/danielberkompas))
- Migration task succeeds on empty table [\#82](https://github.com/danielberkompas/cloak/pull/82) ([kevin-j-m](https://github.com/kevin-j-m))
- Update docs [\#80](https://github.com/danielberkompas/cloak/pull/80) ([hl](https://github.com/hl))
- Upgrade Flow to 0.14 [\#79](https://github.com/danielberkompas/cloak/pull/79) ([mikeastock](https://github.com/mikeastock))

## [v0.9.0](https://github.com/danielberkompas/cloak/tree/v0.9.0) (2018-09-29)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.8.0...v0.9.0)

**Breaking changes:**

- Make Cloak.Vault a GenServer [\#75](https://github.com/danielberkompas/cloak/issues/75)

**Merged pull requests:**

- \[\#75\] Make Cloak.Vault a GenServer [\#78](https://github.com/danielberkompas/cloak/pull/78) ([danielberkompas](https://github.com/danielberkompas))

## [v0.8.0](https://github.com/danielberkompas/cloak/tree/v0.8.0) (2018-09-22)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.7.0...v0.8.0)

**Closed issues:**

- convert Cloak errors into Ecto errors [\#74](https://github.com/danielberkompas/cloak/issues/74)
- Support migrations with non-integer `:id` field [\#70](https://github.com/danielberkompas/cloak/issues/70)
- Roadmap [\#66](https://github.com/danielberkompas/cloak/issues/66)

**Merged pull requests:**

- Support :binary\_ids via cursor paging [\#73](https://github.com/danielberkompas/cloak/pull/73) ([danielberkompas](https://github.com/danielberkompas))
- Add a link to the 0.6.x to 0.7.x migration guide to readme [\#72](https://github.com/danielberkompas/cloak/pull/72) ([4141done](https://github.com/4141done))
- Do not fail migration task when running on schema linked to empty table [\#69](https://github.com/danielberkompas/cloak/pull/69) ([tizpuppi](https://github.com/tizpuppi))

## [v0.7.0](https://github.com/danielberkompas/cloak/tree/v0.7.0) (2018-08-23)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.7.0-alpha.2...v0.7.0)

**Merged pull requests:**

- Prepare for 0.7 release [\#68](https://github.com/danielberkompas/cloak/pull/68) ([danielberkompas](https://github.com/danielberkompas))
- Add support for PBKDF2 for blind indexing [\#67](https://github.com/danielberkompas/cloak/pull/67) ([michaelherold](https://github.com/michaelherold))

## [v0.7.0-alpha.2](https://github.com/danielberkompas/cloak/tree/v0.7.0-alpha.2) (2018-04-25)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.7.0-alpha.1...v0.7.0-alpha.2)

**Closed issues:**

- \(Postgrex.Error\) ERROR 22021 \(character\_not\_in\_repertoire\) [\#65](https://github.com/danielberkompas/cloak/issues/65)

**Merged pull requests:**

- Update install.md [\#64](https://github.com/danielberkompas/cloak/pull/64) ([mhussa](https://github.com/mhussa))
- Improve nil support in Ecto types [\#63](https://github.com/danielberkompas/cloak/pull/63) ([danielberkompas](https://github.com/danielberkompas))

## [v0.7.0-alpha.1](https://github.com/danielberkompas/cloak/tree/v0.7.0-alpha.1) (2018-03-21)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.6.2...v0.7.0-alpha.1)

**Closed issues:**

- Cloak.AES.CTR `encrypt/2` not explicitly called? [\#38](https://github.com/danielberkompas/cloak/issues/38)
- Recommendations for data migrations [\#29](https://github.com/danielberkompas/cloak/issues/29)

**Merged pull requests:**

- Rewrite mix.cloak.migrate [\#62](https://github.com/danielberkompas/cloak/pull/62) ([danielberkompas](https://github.com/danielberkompas))
- Vaults [\#60](https://github.com/danielberkompas/cloak/pull/60) ([danielberkompas](https://github.com/danielberkompas))

## [v0.6.2](https://github.com/danielberkompas/cloak/tree/v0.6.2) (2018-03-19)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.6.1...v0.6.2)

**Closed issues:**

- Is poison optional? [\#59](https://github.com/danielberkompas/cloak/issues/59)
- Clarification on usage of 'default' in documents [\#58](https://github.com/danielberkompas/cloak/issues/58)
- Argument error [\#57](https://github.com/danielberkompas/cloak/issues/57)
- Use with mnesia? [\#55](https://github.com/danielberkompas/cloak/issues/55)

**Merged pull requests:**

- \[Documentation\] Fix small typo: SHA265 -\> SHA256 [\#56](https://github.com/danielberkompas/cloak/pull/56) ([connorlay](https://github.com/connorlay))

## [v0.6.1](https://github.com/danielberkompas/cloak/tree/v0.6.1) (2018-02-25)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.6.0...v0.6.1)

**Merged pull requests:**

- bugfix\(cipher?\): Rescue from UndefinedFunctionError instead of using … [\#54](https://github.com/danielberkompas/cloak/pull/54) ([tomciopp](https://github.com/tomciopp))

## [v0.6.0](https://github.com/danielberkompas/cloak/tree/v0.6.0) (2018-02-24)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.5.0...v0.6.0)

**Merged pull requests:**

- Add support for encrypted Ecto String and Integer Array types [\#53](https://github.com/danielberkompas/cloak/pull/53) ([boydm](https://github.com/boydm))
- perf\(Cloak.Config.all/0\): remove calls to ensure\_loaded when checking… [\#51](https://github.com/danielberkompas/cloak/pull/51) ([tomciopp](https://github.com/tomciopp))

## [v0.5.0](https://github.com/danielberkompas/cloak/tree/v0.5.0) (2018-01-06)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.4.0...v0.5.0)

**Closed issues:**

- Migrations in multi tenant applications [\#43](https://github.com/danielberkompas/cloak/issues/43)
- Proposal AES GCM cipher as default Cipher [\#33](https://github.com/danielberkompas/cloak/issues/33)

**Merged pull requests:**

- Add EncryptedTimeField [\#50](https://github.com/danielberkompas/cloak/pull/50) ([danielberkompas](https://github.com/danielberkompas))
- Update the documentation sidebar [\#49](https://github.com/danielberkompas/cloak/pull/49) ([danielberkompas](https://github.com/danielberkompas))
- Add DateTime field, better docs [\#48](https://github.com/danielberkompas/cloak/pull/48) ([danielberkompas](https://github.com/danielberkompas))
- refactor\(Cloak.Config.all/0\): Find ciphers by checking if the module … [\#47](https://github.com/danielberkompas/cloak/pull/47) ([tomciopp](https://github.com/tomciopp))
- feat\(Date Types\): add EncryptedDateField, and EncryptedNaiveDatetimeF… [\#46](https://github.com/danielberkompas/cloak/pull/46) ([tomciopp](https://github.com/tomciopp))

## [v0.4.0](https://github.com/danielberkompas/cloak/tree/v0.4.0) (2018-01-02)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.3.3...v0.4.0)

**Fixed bugs:**

- instructions to cloak plain text fields [\#17](https://github.com/danielberkompas/cloak/issues/17)

**Closed issues:**

- Make json library configurable [\#44](https://github.com/danielberkompas/cloak/issues/44)
- Encryption Arguement Error [\#41](https://github.com/danielberkompas/cloak/issues/41)
- \*\* \(MatchError\) no match of right hand side value: false [\#40](https://github.com/danielberkompas/cloak/issues/40)
- Proposal / Forthcoming PRs: Multiple Ciphers With Keys [\#36](https://github.com/danielberkompas/cloak/issues/36)

**Merged pull requests:**

- Modernize codebase for new release [\#45](https://github.com/danielberkompas/cloak/pull/45) ([danielberkompas](https://github.com/danielberkompas))
- \[\#33\] Add galois counter mode cipher [\#42](https://github.com/danielberkompas/cloak/pull/42) ([tomciopp](https://github.com/tomciopp))
- Fix typespecs / dialyzer errors across the board [\#39](https://github.com/danielberkompas/cloak/pull/39) ([asummers](https://github.com/asummers))
- Allow multiple concurrent ciphers to encrypt [\#37](https://github.com/danielberkompas/cloak/pull/37) ([asummers](https://github.com/asummers))

## [v0.3.3](https://github.com/danielberkompas/cloak/tree/v0.3.3) (2017-09-08)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.3.2...v0.3.3)

**Closed issues:**

- EncryptedIntegerField and EncryptedFloat field do not cast properly [\#35](https://github.com/danielberkompas/cloak/issues/35)

## [v0.3.2](https://github.com/danielberkompas/cloak/tree/v0.3.2) (2017-08-05)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.3.0...v0.3.2)

**Closed issues:**

- Compile warnings [\#34](https://github.com/danielberkompas/cloak/issues/34)
- Allow key to be in Application env [\#31](https://github.com/danielberkompas/cloak/issues/31)
- Add salt option to cloak for increased security [\#26](https://github.com/danielberkompas/cloak/issues/26)
- How to encrypt with user's own key instead of key from config? [\#24](https://github.com/danielberkompas/cloak/issues/24)
- index on encryption\_version [\#23](https://github.com/danielberkompas/cloak/issues/23)
- Adding interoperability with attr\_encrypted? [\#22](https://github.com/danielberkompas/cloak/issues/22)
- Provide Vault Transit cipher [\#21](https://github.com/danielberkompas/cloak/issues/21)

**Merged pull requests:**

- Add ability to pull cipher key from OTP app env [\#32](https://github.com/danielberkompas/cloak/pull/32) ([tielur](https://github.com/tielur))
- Add `prepare_changes` example to module doc for use with ecto 2.0 [\#27](https://github.com/danielberkompas/cloak/pull/27) ([kgautreaux](https://github.com/kgautreaux))
- clean up compile warnings under Elixir 1.4 [\#25](https://github.com/danielberkompas/cloak/pull/25) ([boydm](https://github.com/boydm))

## [v0.3.0](https://github.com/danielberkompas/cloak/tree/v0.3.0) (2016-09-16)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.2.3...v0.3.0)

**Merged pull requests:**

- Rely on configuration at runtime [\#20](https://github.com/danielberkompas/cloak/pull/20) ([danielberkompas](https://github.com/danielberkompas))

## [v0.2.3](https://github.com/danielberkompas/cloak/tree/v0.2.3) (2016-09-16)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.2.2...v0.2.3)

**Fixed bugs:**

- mix cloak.migrate doesn't update encryption\_version field [\#16](https://github.com/danielberkompas/cloak/issues/16)

**Closed issues:**

- cloak migration not running [\#18](https://github.com/danielberkompas/cloak/issues/18)
- Issue integration with Ecto2? [\#12](https://github.com/danielberkompas/cloak/issues/12)
- Support for Ecto 2.0 [\#10](https://github.com/danielberkompas/cloak/issues/10)
- :system AES keys aren't getting base64 decoded [\#9](https://github.com/danielberkompas/cloak/issues/9)

**Merged pull requests:**

- \[\#16\] Update encryption version in cloak.migrate [\#19](https://github.com/danielberkompas/cloak/pull/19) ([danielberkompas](https://github.com/danielberkompas))
- Fix validation bug in cloak.migrate [\#15](https://github.com/danielberkompas/cloak/pull/15) ([bgeihsgt](https://github.com/bgeihsgt))
- Add key generation example to README. [\#14](https://github.com/danielberkompas/cloak/pull/14) ([ghost](https://github.com/ghost))
- Add deps badge to README [\#13](https://github.com/danielberkompas/cloak/pull/13) ([rrrene](https://github.com/rrrene))

## [v0.2.2](https://github.com/danielberkompas/cloak/tree/v0.2.2) (2016-05-20)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.2.1...v0.2.2)

**Closed issues:**

- Cloak.EncryptedMapField strange Poison errors [\#6](https://github.com/danielberkompas/cloak/issues/6)
- How to generate keys? [\#5](https://github.com/danielberkompas/cloak/issues/5)

**Merged pull requests:**

- Decode AES environment variable keys from base64 [\#11](https://github.com/danielberkompas/cloak/pull/11) ([philss](https://github.com/philss))

## [v0.2.1](https://github.com/danielberkompas/cloak/tree/v0.2.1) (2016-04-06)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.2.0...v0.2.1)

**Merged pull requests:**

- Update examples to reflect the remotion of Cloak.Model [\#4](https://github.com/danielberkompas/cloak/pull/4) ([philss](https://github.com/philss))

## [v0.2.0](https://github.com/danielberkompas/cloak/tree/v0.2.0) (2015-12-16)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.1.0...v0.2.0)

**Merged pull requests:**

- Added sample migration to README [\#3](https://github.com/danielberkompas/cloak/pull/3) ([mspanc](https://github.com/mspanc))
- Added ability to store keys in the environment variables [\#2](https://github.com/danielberkompas/cloak/pull/2) ([mspanc](https://github.com/mspanc))
- Inform that key must be 16, 24 or 32 bytes long [\#1](https://github.com/danielberkompas/cloak/pull/1) ([mspanc](https://github.com/mspanc))

## [v0.1.0](https://github.com/danielberkompas/cloak/tree/v0.1.0) (2015-09-22)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/v0.1.0-pre...v0.1.0)

## [v0.1.0-pre](https://github.com/danielberkompas/cloak/tree/v0.1.0-pre) (2015-09-16)

[Full Changelog](https://github.com/danielberkompas/cloak/compare/2bd17019e285b55c5c218cc842537bf9280f24c3...v0.1.0-pre)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
