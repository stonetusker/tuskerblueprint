import { Grid } from '@material-ui/core';

import {
  EntityAboutCard,
  EntityDependsOnComponentsCard,
  EntityDependsOnResourcesCard,
  EntityLayout,
  EntityLinksCard,
  EntitySwitch,
  isComponentType,
} from '@backstage/plugin-catalog';

import { EntityCatalogGraphCard } from '@backstage/plugin-catalog-graph';

import { EntityApiDefinitionCard } from '@backstage/plugin-api-docs';

import { EntityTechdocsContent } from '@backstage/plugin-techdocs';

import {
  EntityKubernetesContent,
  isKubernetesAvailable,
} from '@backstage/plugin-kubernetes';

import {
  EntityGithubActionsContent,
  isGithubActionsAvailable,
} from '@backstage-community/plugin-github-actions';

import {
  EntityArgoCDOverviewCard,
  isArgocdAvailable,
} from '@roadiehq/backstage-plugin-argo-cd';

const overviewContent = (
  <Grid container spacing={3} alignItems="stretch">
    <Grid item md={6} xs={12}>
      <EntityAboutCard variant="gridItem" />
    </Grid>

    <Grid item md={6} xs={12}>
      <EntityCatalogGraphCard
        variant="gridItem"
        height={400}
      />
    </Grid>

    <Grid item md={6} xs={12}>
      <EntityLinksCard />
    </Grid>

    <Grid item md={6} xs={12}>
      <EntityDependsOnComponentsCard variant="gridItem" />
    </Grid>

    <Grid item md={6} xs={12}>
      <EntityDependsOnResourcesCard variant="gridItem" />
    </Grid>

    <EntitySwitch>
      <EntitySwitch.Case if={isArgocdAvailable}>
        <Grid item md={12} xs={12}>
          <EntityArgoCDOverviewCard />
        </Grid>
      </EntitySwitch.Case>
    </EntitySwitch>
  </Grid>
);

const serviceEntityPage = (
  <EntityLayout>
    <EntityLayout.Route
      path="/"
      title="Overview"
    >
      {overviewContent}
    </EntityLayout.Route>

    <EntityLayout.Route
      path="/docs"
      title="Docs"
    >
      <EntityTechdocsContent />
    </EntityLayout.Route>

    <EntityLayout.Route
      if={isKubernetesAvailable}
      path="/kubernetes"
      title="Kubernetes"
    >
      <EntityKubernetesContent refreshIntervalMs={10000} />
    </EntityLayout.Route>

    <EntityLayout.Route
      if={isGithubActionsAvailable}
      path="/ci-cd"
      title="CI/CD"
    >
      <EntityGithubActionsContent />
    </EntityLayout.Route>
  </EntityLayout>
);

const apiEntityPage = (
  <EntityLayout>
    <EntityLayout.Route
      path="/"
      title="Overview"
    >
      <Grid container spacing={3}>
        <Grid item md={6} xs={12}>
          <EntityAboutCard />
        </Grid>

        <Grid item md={6} xs={12}>
          <EntityLinksCard />
        </Grid>

        <Grid item xs={12}>
          <EntityApiDefinitionCard />
        </Grid>
      </Grid>
    </EntityLayout.Route>
  </EntityLayout>
);

const defaultEntityPage = (
  <EntityLayout>
    <EntityLayout.Route
      path="/"
      title="Overview"
    >
      {overviewContent}
    </EntityLayout.Route>
  </EntityLayout>
);

export const entityPage = (
  <EntitySwitch>
    <EntitySwitch.Case if={isComponentType('service')}>
      {serviceEntityPage}
    </EntitySwitch.Case>

    <EntitySwitch.Case if={entity => entity.kind === 'API'}>
      {apiEntityPage}
    </EntitySwitch.Case>

    <EntitySwitch.Case>
      {defaultEntityPage}
    </EntitySwitch.Case>
  </EntitySwitch>
);
