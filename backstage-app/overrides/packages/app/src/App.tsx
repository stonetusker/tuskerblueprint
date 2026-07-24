import { Navigate, Route } from 'react-router-dom';

import { apiDocsPlugin, ApiExplorerPage } from '@backstage/plugin-api-docs';

import {
  CatalogEntityPage,
  CatalogIndexPage,
  catalogPlugin,
} from '@backstage/plugin-catalog';

import {
  catalogImportPlugin,
  CatalogImportPage,
} from '@backstage/plugin-catalog-import';

import {
  ScaffolderPage,
  scaffolderPlugin,
} from '@backstage/plugin-scaffolder';

import { orgPlugin } from '@backstage/plugin-org';

import { SearchPage } from '@backstage/plugin-search';

import {
  TechDocsIndexPage,
  techdocsPlugin,
  TechDocsReaderPage,
} from '@backstage/plugin-techdocs';

import { UserSettingsPage } from '@backstage/plugin-user-settings';

import {
  CatalogGraphPage,
  catalogGraphPlugin,
} from '@backstage/plugin-catalog-graph';

import { createApp } from '@backstage/app-defaults';

import {
  AppRouter,
  FlatRoutes,
} from '@backstage/core-app-api';

import {
  AlertDisplay,
  OAuthRequestDialog,
  SignInPage,
} from '@backstage/core-components';

import { entityPage } from './components/catalog/EntityPage';

const app = createApp({
  bindRoutes({ bind }) {
    bind(catalogPlugin.externalRoutes, {
      createComponent: scaffolderPlugin.routes.root,
      viewTechDoc: techdocsPlugin.routes.docRoot,
      createFromTemplate: scaffolderPlugin.routes.selectedTemplate,
    });

    bind(apiDocsPlugin.externalRoutes, {
      registerApi: catalogImportPlugin.routes.importPage,
    });

    bind(scaffolderPlugin.externalRoutes, {
      registerComponent: catalogImportPlugin.routes.importPage,
      viewTechDoc: techdocsPlugin.routes.docRoot,
    });

    bind(orgPlugin.externalRoutes, {
      catalogIndex: catalogPlugin.routes.catalogIndex,
    });

    bind(catalogGraphPlugin.externalRoutes, {
      catalogEntity: catalogPlugin.routes.catalogEntity,
    });
  },

  components: {
    SignInPage: props => (
      <SignInPage
        {...props}
        auto
        providers={['github']}
      />
    ),
  },
});

const routes = (
  <FlatRoutes>
    <Route
      path="/"
      element={<Navigate to="/catalog" replace />}
    />

    <Route
      path="/catalog"
      element={<CatalogIndexPage />}
    />

    <Route
      path="/catalog/:namespace/:kind/:name"
      element={<CatalogEntityPage />}
    >
      {entityPage}
    </Route>

    <Route
      path="/docs"
      element={<TechDocsIndexPage />}
    />

    <Route
      path="/docs/:namespace/:kind/:name/*"
      element={<TechDocsReaderPage />}
    />

    <Route
      path="/create"
      element={<ScaffolderPage />}
    />

    <Route
      path="/api-docs"
      element={<ApiExplorerPage />}
    />

    <Route
      path="/catalog-import"
      element={<CatalogImportPage />}
    />

    <Route
      path="/search"
      element={<SearchPage />}
    />

    <Route
      path="/settings"
      element={<UserSettingsPage />}
    />

    <Route
      path="/catalog-graph"
      element={<CatalogGraphPage />}
    />
  </FlatRoutes>
);

export default app.createRoot(
  <>
    <AlertDisplay transientTimeoutMs={2500} />
    <OAuthRequestDialog />

    <AppRouter>
      {routes}
    </AppRouter>
  </>,
);
