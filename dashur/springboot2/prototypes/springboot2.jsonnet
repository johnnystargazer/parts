// @apiVersion 0.1
// @name com.dashur.springboot2
// @description Dashur springboot app
// @shortDescription springboot2 app
// @param namespace string Namespace in which to put the application
// @param name string Metadata name for each of the deployment components
// @param version string version

local k = import 'k.libsonnet';
local springboot2 = import 'dashur/springboot2/springboot2.libsonnet';
local defaultConfig = import 'dashur/springboot2/globals.libsonnet';
local namespace = import 'param://namespace';
local name = import 'param://name';
local version = import 'param://version';

    local project = defaultConfig.app[name];
    local defaults = {
      k8:  defaultConfig.env[namespace],
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
  springboot2.parts.configMap(updated),
  springboot2.parts.deployment.nonNfs(updated),
  springboot2.parts.secret(updated),
  springboot2.parts.svc(updated)
  ])