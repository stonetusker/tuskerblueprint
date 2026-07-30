import { createBackendModule } from '@backstage/backend-plugin-api';

import {
  AuthorizeResult,
  PolicyDecision,
} from '@backstage/plugin-permission-common';

import {
  PermissionPolicy,
  PolicyQuery,
  PolicyQueryUser,
} from '@backstage/plugin-permission-node';

import {
  policyExtensionPoint,
} from '@backstage/plugin-permission-node/alpha';

const restrictedPermissions = new Set([
  'catalog.entity.delete',
  'catalog.location.delete',
]);

class TuskerPermissionPolicy implements PermissionPolicy {
  async handle(
    request: PolicyQuery,
    user?: PolicyQueryUser,
  ): Promise<PolicyDecision> {
    if (!user) {
      return {
        result: AuthorizeResult.DENY,
      };
    }

    const userEntityRef = user.info.userEntityRef;

    const ownershipEntityRefs =
      user.info.ownershipEntityRefs ?? [];

    const isPlatformAdministrator =
      userEntityRef === 'user:default/subeeshes' ||
      ownershipEntityRefs.includes(
        'group:default/platform-team',
      );

    if (
      restrictedPermissions.has(request.permission.name) &&
      !isPlatformAdministrator
    ) {
      return {
        result: AuthorizeResult.DENY,
      };
    }

    return {
      result: AuthorizeResult.ALLOW,
    };
  }
}

export default createBackendModule({
  pluginId: 'permission',
  moduleId: 'tusker-permission-policy',

  register(registration) {
    registration.registerInit({
      deps: {
        policy: policyExtensionPoint,
      },

      async init({ policy }) {
        policy.setPolicy(
          new TuskerPermissionPolicy(),
        );
      },
    });
  },
});
