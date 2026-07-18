import { type Build } from 'cmake-ts-gen';

const build: Build = {
    common: {
        project: 'libblake3',
        archs: ['x64'],
        variables: [],
        copy: {},
        defines: [],
        options: [],
        subdirectories: ['BLAKE3/c'],
        libraries: {
            blake3: {}
        },
        buildDir: 'build',
        buildOutDir: '../libs',
        buildFlags: [],
    },
    platforms: {
        win32: {
            windows: {},
        },
        linux: {
            linux: {},
        },
        darwin: {
            macos: {}
        }
    }
}

export default build;