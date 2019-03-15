local BuildWithDiffTags(version='go-latest', tags='latest') = {
  name: 'build-' + version,
  pull: 'always',
  image: 'plugins/docker',
  settings: {
    dockerfile: 'docker/' + version + '/Dockerfile',
    password: {
      from_secret: 'docker_password'
    },
    username: {
      from_secret: 'docker_username'
    },
    repo: 'techknowlogick/xgo',
    tags: tags
  },
  when: {
    branch: ['master'],
    event: {exclude: ['pull_request']}
  }
};

local BuildStep(version='go-latest') = BuildWithDiffTags(version, version);

{
kind: 'pipeline',
name: 'default',
steps: [
  BuildStep('go-1.12.1'),
  BuildStep('go-1.12.x'),
  BuildStep('go-1.11.6'),
  BuildStep('go-1.11.x'),
  BuildWithDiffTags(),
]
}