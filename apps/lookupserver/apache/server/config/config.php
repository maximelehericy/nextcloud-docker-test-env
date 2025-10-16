<?php

/**
 * SPDX-FileCopyrightText: 2016 Nextcloud GmbH and Nextcloud contributors
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

// Lookup-Server Config

$CONFIG = [
	//DB
	'DB' => [
		'host' => 'db',
		'db' => 'lookup',
		'user' => 'lookup',
		'pass' => 'lookup',
	],

	// error verbose
	'ERROR_VERBOSE' => true,

	// logfile
	'LOG' => '/var/www/html/log/lookup.log',

	// replication logfile
	'REPLICATION_LOG' => '/var/www/html/log/lookup_replication.log',

	// max user search page. limit the maximum number of pages to avoid scraping.
	'MAX_SEARCH_PAGE' => 10,

	// max requests per IP and 10min.
	'MAX_REQUESTS' => 10000,

	// credential to read the replication log. IMPORTANT!! SET TO SOMETHING SECURE!!
	'REPLICATION_AUTH' => 'lookup',

	// credential to read the slave replication log. Replication slaves are read only and don't get the authkey. IMPORTANT!! SET TO SOMETHING SECURE!!
	'SLAVEREPLICATION_AUTH' => 'lookup',

	// the list of remote replication servers that should be queried in the cronjob
	//'REPLICATION_HOSTS' => [
	//	'https://lookup:lookup@lookup.local.mlh.ovh/replication'
	//],

	// ip black list. usefull to block spammers.
	'IP_BLACKLIST' => [
		'333.444.555.',
		'666.777.888.',
	],

	// spam black list. usefull to block spammers.
	'SPAM_BLACKLIST' => [
	],

	// Email sender address
	'EMAIL_SENDER' => 'maxime@nextcloud.com',

	// Public Server Url
	'PUBLIC_URL' => 'https://lookup.local.mlh.ovh',

	// does the lookup server run in a global scale setup
	'GLOBAL_SCALE' => true,

	// auth token
	'AUTH_KEY' => 'lookup',

    // twitter oauth credentials, needed to perform twitter verification
	'TWITTER' => [
		'CONSUMER_KEY' => '',
		'CONSUMER_SECRET' => '',
		'ACCESS_TOKEN' => '',
		'ACCESS_TOKEN_SECRET' => '',
	],

	// enforce listing of instance instead of auto-generating it based on users' account
	// 'INSTANCES' => [
	//  'node1.local.mlh.ovh',
	//  'node2.local.mlh.ovh',
	// ]
];
