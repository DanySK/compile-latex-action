/*
 * Copyright (C) 2010-2022, Danilo Pianini and contributors
 * listed, for each module, in the respective subproject's build.gradle.kts file.
 *
 * This file is part of Alchemist, and is distributed under the terms of the
 * GNU General Public License, with a linking exception,
 * as described in the file LICENSE in the Alchemist distribution's top directory.
 */

var publishCmd = `
docker tag \${process.env.IMAGE_NAME}:latest \${process.env.IMAGE_NAME}:\${nextRelease.version}
docker push --all-tags \${process.env.IMAGE_NAME}
`
var config = require('semantic-release-preconfigured-conventional-commits');
config.plugins.push(
    [
        "semantic-release-replace-plugin",
        {
            "replacements": [
                {
                    "files": ["action.yml"],
                    "from": "image: .*",
                    "to": "image: danysk/compile-latex-action:${nextRelease.version}",
                    "results": [
                        {
                            "file": "action.yml",
                            "hasChanged": true,
                            "numMatches": 1,
                            "numReplacements": 1,
                        }
                    ],
                    "countMatches": true
                }
            ]
        }
    ],
    ["@semantic-release/exec", {
        "publishCmd": publishCmd,
    }],
    "@semantic-release/github",
    [
        "@semantic-release/git",
        {
            "assets": ["action.yml"],
        }
    ]
)
module.exports = config
