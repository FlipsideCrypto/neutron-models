{% docs __overview__ %}

# Welcome to the Flipside Crypto neutron Models Documentation!

## **What does this documentation cover?**
The documentation included here details the design of the neutron tables and views available via [Flipside Crypto.](https://flipsidecrypto.xyz/) For more information on how these models are built, please see [the github repository.](https://github.com/FlipsideCrypto/neutron-models)

## **How do I use these docs?**
The easiest way to navigate this documentation is to use the Quick Links below. These links will take you to the documentation for each table, which contains a description, a list of the columns, and other helpful information.

If you are experienced with dbt docs, feel free to use the sidebar to navigate the documentation, as well as explore the relationships between tables and the logic building them.

There is more information on how to use dbt docs in the last section of this document.

## **Quick Links to Table Documentation**

**Click on the links below to jump to the documentation for each schema.**

### Core Tables (neutron.core)

**Dimension Tables:**
- [dim_labels](https://flipsidecrypto.github.io/neutron/#!/model/model.neutron_models.core__dim_labels)

**Fact Tables:**
- [fact_blocks](https://flipsidecrypto.github.io/neutron/#!/model/model.neutron_models.core__fact_blocks)
- [fact_msgs](https://flipsidecrypto.github.io/neutron/#!/model/model.neutron_models.core__fact_msgs)
- [fact_msg_attributes](https://flipsidecrypto.github.io/neutron/#!/model/model.neutron_models.core__fact_msg_attributes)
- [fact_transactions](https://flipsidecrypto.github.io/neutron/#!/model/model.neutron_models.core__fact_transactions)
- [fact_transfers](https://flipsidecrypto.github.io/neutron/#!/model/model.neutron_models.core__fact_transfers)
  
### Price Tables (neutron.price)
- [dim_asset_metadata](https://flipsidecrypto.github.io/neutron/#!/model/model.neutron_models.price__dim_asset_metadata)
- [fact_prices_ohlc_hourly](https://flipsidecrypto.github.io/neutron/#!/model/model.neutron_models.price__fact_prices_ohlc_hourly)
- [ez_asset_metadata](https://flipsidecrypto.github.io/neutron/#!/model/model.neutron_models.price__ez_asset_metadata)
- [ez_prices_hourly](https://flipsidecrypto.github.io/neutron/#!/model/model.neutron_models.price__ez_prices_hourly)

## **Helpful User-Defined Functions (UDFs)**

UDFs are custom functions built by the Flipside team that can be used in your queries to make your life easier. 

Please visit [LiveQuery Functions Overview](https://flipsidecrypto.github.io/livequery-models/#!/overview) for a full list of helpful UDFs.

## **Data Model Overview**

The Core models are built a few different ways, but the core fact tables are built using three layers of sql models: **bronze, silver, and gold (or core).**

- Bronze: Data is loaded in from the source as a view
- Silver: All necessary parsing, filtering, de-duping, and other transformations are done here
- Gold (or Core): Final views and tables that are available publicly

The dimension tables are sourced from a variety of on-chain and off-chain sources.

Convenience views (denoted ez_) are a combination of different fact and dimension tables. These views are built to make it easier to query the data.

## **Using dbt docs**
### Navigation

You can use the ```Project``` and ```Database``` navigation tabs on the left side of the window to explore the models in the project.

### Database Tab

This view shows relations (tables and views) grouped into database schemas. Note that ephemeral models are *not* shown in this interface, as they do not exist in the database.

### Graph Exploration

You can click the blue icon on the bottom-right corner of the page to view the lineage graph of your models.

On model pages, you'll see the immediate parents and children of the model you're exploring. By clicking the Expand button at the top-right of this lineage pane, you'll be able to see all of the models that are used to build, or are built from, the model you're exploring.

Once expanded, you'll be able to use the ```--models``` and ```--exclude``` model selection syntax to filter the models in the graph. For more information on model selection, check out the [dbt docs](https://docs.getdbt.com/docs/model-selection-syntax).

Note that you can also right-click on models to interactively filter and explore the graph.


### **More information**
- [Flipside](https://flipsidecrypto.xyz/)
- [Data Studio](https://flipsidecrypto.xyz/studio)
- [Tutorials](https://docs.flipsidecrypto.com/our-data/tutorials)
- [Github](https://github.com/FlipsideCrypto/neutron-models)
- [What is dbt?](https://docs.getdbt.com/docs/introduction)

{% enddocs %}