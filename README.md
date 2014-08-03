dashing-zabbix
==============

Two widgets groups which illustrate the trigger states in Zabbix.

The first group of widgets show the numbers of triggers grouped by priority, the other widgets show the hosts which relate to these numbers.

My widgets were inspired by the original Dashing<>Zabbix widget ( https://gist.github.com/chojayr/7401426 ), but remove some oddities. Mainly the CSS animation was quite annoying and the code itself contained lot's of redundancy. 

screenshot
----------

![Zabbix widgets in action](https://gist.githubusercontent.com/tolleiv/68b9fddfa5d6960f3455/raw/28d3d463a67edd8deb132d909e4ab335c3bc699e/zabbix-dashing.png)

usage
-----

* Create a new dashing application or use your existing one (see: [Dashing Getting Started](http://shopify.github.io/dashing/#setup))
* Copy zabbix_credentials.example.rb to zabbix_credentials.rb and insert your Zabbix server credentials
* Copy the contents of the jobs and widgets directories into the related dashing application folders
* Create a new dashboard with the widgets or reuse the dashboards/zabbix.rb

credits
-------

* Original Zabbix Widgets: [https://gist.github.com/chojayr/7401426](https://gist.github.com/chojayr/7401426)
* Dashing: [http://shopify.github.io/dashing/](http://shopify.github.io/dashing/)
* zabby: [https://github.com/Pragmatic-Source/zabby](https://github.com/Pragmatic-Source/zabby)
