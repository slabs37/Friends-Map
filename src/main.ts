import * as rm from "https://deno.land/x/remapper@4.2.3/src/mod.ts"
import * as bundleInfo from '../bundleinfo.json' with { type: 'json' }

const pipeline = await rm.createPipeline({ bundleInfo })

const bundle = rm.loadBundle(bundleInfo)
const materials = bundle.materials
const prefabs = bundle.prefabs

// ----------- { SCRIPT } -----------

async function doMap(file: rm.DIFFICULTY_NAME) {
    const map = await rm.readDifficultyV3(pipeline, file)

    map.difficultyInfo.requirements = [
        'Chroma',
        'Noodle Extensions',
        'Vivify',
    ]
    rm.environmentRemoval(map, ['Environment', 'GameCore'])

    map.difficultyInfo.settingsSetter = {
        graphics: {
            maxShockwaveParticles: 0,
        },
        chroma: {
            disableEnvironmentEnhancements: false,
        },
        playerOptions: {
            leftHanded: rm.BOOLEAN.False,
        },
        colors: {},
        environments: {},
    }

    rm.setRenderingSettings(map, {
        qualitySettings: {
            realtimeReflectionProbes: rm.BOOLEAN.True,
            shadows: rm.SHADOWS.HardOnly,
            shadowDistance: 64,
            shadowResolution: rm.SHADOW_RESOLUTION.High,
            softParticles: rm.BOOLEAN.True,
        },
        renderSettings: {
            fog: rm.BOOLEAN.True,
            fogEndDistance: 64,
        },
    })


        const stage = prefabs.mainforest.instantiate(map, 0)

        rm.assignObjectPrefab(map, {
            saber: {
                type: 'Left',
                asset: prefabs.handl.path,
                trailAsset: materials['sabernotrail'].path,
            }
        })
        rm.assignObjectPrefab(map, {
            saber: {
                type: 'Right',
                asset: prefabs.handr.path,
                trailAsset: materials['sabernotrail'].path,
            }
        })

        rm.assignObjectPrefab(map, {
            beat: 26,
            saber: {
                type: 'Both',
                asset: prefabs.umbrella.path,
                trailAsset: materials['sabertrail'].path,
            }
        })
        rm.assignObjectPrefab(map, {
            beat: 554,
            saber: {
                type: 'Both',
                asset: prefabs.racket.path,
                trailAsset: materials['sabertrail2'].path,
            }
        })

        rm.assignObjectPrefab(map, {
            colorNotes: {
                track: 'MainNotes',
                asset: prefabs['cellnote'].path,
                debrisAsset: prefabs['cellnotedebris'].path,
                anyDirectionAsset: prefabs['cellnotedot'].path
            }
        })
        map.colorNotes.forEach(note => {
            note.track.add('MainNotes')
        })


}

await Promise.all([
    doMap('ExpertPlusStandard')
])

// ----------- { OUTPUT } -----------

pipeline.export({
    outputDirectory: '../Frends'
})
// deno run --allow-all src/main.ts