## Kibana Spaces
* Spaces enable you to organize your dashboards and other saved objects into meaningful categories.
* Once inside a space, you see only the dashboards and saved objects that belong to that space.
### Previliges:
* The kibana_admin role or equivalent is required to manage Spaces.



### Kibana Multi-tenancy
**There are two approaches to supporting multi-tenancy in Kibana:**

**Recommended:** Create a space and a limited role for each tenant, and configure each user with the appropriate role. See Securing access to Kibana for more details.

**Other Approach:** Set up separate Kibana instances to work with a single Elasticsearch cluster by changing the kibana.index setting in your kibana.yml file.(No support from 8.0)