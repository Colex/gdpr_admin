# Changelog

### [1.3.1](https://www.github.com/Colex/gdpr_admin/compare/v1.3.0...v1.3.1) (2023-03-29)


### Bug Fixes

* do not attempt to anonymize version's object if no policy found ([5685b13](https://www.github.com/Colex/gdpr_admin/commit/5685b138d6f41dffce84be23a62900fba43342ed))

## [1.3.0](https://www.github.com/Colex/gdpr_admin/compare/v1.2.0...v1.3.0) (2023-03-01)


### Features

* add helper for scoping data by given date ([5352e29](https://www.github.com/Colex/gdpr_admin/commit/5352e29e028dd38be8e2c4fe24addcfdf0b8c968))

## [1.2.0](https://www.github.com/Colex/gdpr_admin/compare/v1.1.0...v1.2.0) (2023-02-16)


### Features

* add default strategy/data policy for paper_trail versions ([2855707](https://www.github.com/Colex/gdpr_admin/commit/2855707b140058b4d114b36c39c4cbb2ec74e08a))
* add extra helper methods for data anonymization ([1e09d78](https://www.github.com/Colex/gdpr_admin/commit/1e09d788d8dc9f4b4b4b22189cdc36a8d0444b6e))
* add job for processing data retention policies ([e92ba61](https://www.github.com/Colex/gdpr_admin/commit/e92ba61c5bb9a3e92397ededc94c233ab0dab74c))
* add option for choosing which queue to use for jobs ([1b1b222](https://www.github.com/Colex/gdpr_admin/commit/1b1b22247a6b2166cd400c5e81b0952eaf1438ca))
* add option to set grace period for erasure and export requests ([389e828](https://www.github.com/Colex/gdpr_admin/commit/389e828efd808de8a28e924321cca2564fc59286))
* add support for custom data retention policies ([9f4c78f](https://www.github.com/Colex/gdpr_admin/commit/9f4c78fb7592b7977dddc2d46fadcfeb4966b349))
* do not create new PaperTrail versions when anonymizing fields ([82a5529](https://www.github.com/Colex/gdpr_admin/commit/82a55290b9b0c4b69c41538d76f871699c1bc67f))
* simplify request types ([e3cfeba](https://www.github.com/Colex/gdpr_admin/commit/e3cfeba031ed723342af86d31ce7f5034af5b156))


### Bug Fixes

* properly validate status transition of gdpr requests ([1a605b4](https://www.github.com/Colex/gdpr_admin/commit/1a605b47d8593ee37dc04e65d4c35729866b5c05))

## [1.1.0](https://www.github.com/Colex/gdpr_admin/compare/v1.0.0...v1.1.0) (2023-02-14)


### Features

* add configuration for tenant and requester classes ([d74d53b](https://www.github.com/Colex/gdpr_admin/commit/d74d53b128d73cbba44bc2f2ac3d7c5198030f68))
* add configuration for tenant isolation adapter ([af9fc25](https://www.github.com/Colex/gdpr_admin/commit/af9fc25f8cfa08ccf65fc34a04fcd52cfbe45fed))
* add helper methods for anonymizing and erasing data ([eb0665b](https://www.github.com/Colex/gdpr_admin/commit/eb0665b2e5d5a654517056c51339f71b7ea19b11))
* add job for processing GDPR requests ([6d3116c](https://www.github.com/Colex/gdpr_admin/commit/6d3116c9a965838364cf8654a36c7ce1b66f518b))
* add option for custom data policies path () ([d08bf6d](https://www.github.com/Colex/gdpr_admin/commit/d08bf6d35f333d0f5f06923e49a3cbf5ccca8b89))
* auto load data policies when eager load is disabled ([ce82cbe](https://www.github.com/Colex/gdpr_admin/commit/ce82cbe169876769cc697ae66efed693ea3cbad3))
* automatically set the current date for the  column ([bab9ab5](https://www.github.com/Colex/gdpr_admin/commit/bab9ab58a4bef96c8728d5b5aea8b1bae5ec084a))


### Bug Fixes

* change process of storing password and password confirmation ([4a96f07](https://www.github.com/Colex/gdpr_admin/commit/4a96f07ca606571c290816963480dc5c1fde743e))
* correct name of configuration fields ([6e310f1](https://www.github.com/Colex/gdpr_admin/commit/6e310f15ea832d105dea11617ee5b5353533a785))
* correctly update password digest in anonymization ([b8ae2af](https://www.github.com/Colex/gdpr_admin/commit/b8ae2af843afdec68e7abf7efba8dfee73e83ad2))
* misconfigured foreign keys in fixtures ([7f44814](https://www.github.com/Colex/gdpr_admin/commit/7f448142c58bb8a4c4e609bdd1032aaadb38c383))
* remove dummy  method ([5cbf391](https://www.github.com/Colex/gdpr_admin/commit/5cbf391752151b295ac993b3b79c988d4ccf1de9))
* ruby linting ([cf57c63](https://www.github.com/Colex/gdpr_admin/commit/cf57c6324ca5182dbda91beaccc706f7186a7801))
