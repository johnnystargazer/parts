local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["parquet-processor"];

local k = import 'k.libsonnet';
local springboot2 = import 'dashur/springboot2/springboot2.libsonnet';
local defaultConfig = import 'dashur/springboot2/globals.libsonnet';
local namespace = params.namespace;
local name = params.name;
local version = params.version;

  local project = defaultConfig[name];
  local defaults = {
    k8: {
      content: 'dev-context',
      namespace: 'dev',
      clusterName: 'cluster.local',
      registryClusterName: 'dev-cluster',
    },
    parameter: [{
      name: 'JAVA_OPTS',
      value: '-Djava.net.preferIPv4Stack=true',
    }],
    imagePullPolicy: 'Always',
    resources: {
      requests: {
        memory: '2200Mi',
        cpu: '1000m',
      },
    },
    appConfig: {
      name: name,
      image:  project.image,
      version: version,
      configLocation: project.config,
    },
  };
    local updated = {
      [sd]:  if std.objectHas(params,sd) then params[sd] else defaults[sd],
      for sd in std.objectFields(defaults)
      };

k.core.v1.list.new([
springboot2.parts.deployment.nfs(updated),
springboot2.parts.secret(updated),
springboot2.parts.svc(updated)
])
