<?php
/**
 * USING SERVERLESS IMAGE TRANSFORMS?
 * @see https://github.com/spacecatninja/craft-imager-x-aws-serverless-transformer
 *
 * If you are using Serverless Image Transforms (which are a Site Starter Default),
 * automatic generation of transforms is not necessary and you may delete this file.
 *
 *
 * USING AUTOMATIC TRANSFORM GENRATION?
 * @see https://imager-x.spacecat.ninja/usage/generate.html
 * @see https://imager-x.spacecat.ninja/usage/named-transforms.html
 *
 * Generating transforms at runtime is a resource heavy operation.
 *
 * Named transforms give Imager X the information needed to pre-generate
 * transforms with a queue job immediately after uploading a new asset.
 */
return [
    'exampleNamedTransform' => [
        'displayName' => 'Example Named Transform',
        'transforms' => [
            ['width' => 300],
            ['width' => 700],
        ],
        'defaults' => [
            'ratio' => 9 / 16,
            'format' => 'webp',
        ],
    ],
];
