/*
 *  Copyright (c) 2020, 2021 Microsoft Corporation
 *
 *  This program and the accompanying materials are made available under the
 *  terms of the Apache License, Version 2.0 which is available at
 *  https://www.apache.org/licenses/LICENSE-2.0
 *
 *  SPDX-License-Identifier: Apache-2.0
 *
 *  Contributors:
 *       Microsoft Corporation - initial API and implementation
 *
 */

plugins {
    `java-library`
}
repositories {
    maven {
        url = uri("https://maven.pkg.github.com/Digital-Ecosystems/edc-ionos-s3/")
        credentials {
            username = project.findProperty("gpr.user") as String? ?: System.getenv("USERNAME_GITHUB")
            password = project.findProperty("gpr.key") as String? ?: System.getenv("TOKEN_GITHUB")
        }
    }
	mavenLocal()
	mavenCentral()
   
}
val javaVersion: String by project
val edcGroup: String by project
val edcVersion: String by project
val postgresqlGroup: String by project
val postgresqlVersion: String by project
val ionosGroup: String by project
val ionosVersion: String by project

dependencies {

    implementation("${edcGroup}:asset-index-sql:$edcVersion")
    implementation("${edcGroup}:policy-definition-store-sql:$edcVersion")
    implementation("${edcGroup}:contract-definition-store-sql:$edcVersion")
    implementation("${edcGroup}:contract-negotiation-store-sql:$edcVersion")
    implementation("${edcGroup}:transfer-process-store-sql:$edcVersion")
    implementation("${edcGroup}:transaction-datasource-spi:$edcVersion")
    implementation("${edcGroup}:sql-pool-apache-commons:$edcVersion")
    implementation("${edcGroup}:transaction-local:$edcVersion")
    implementation("${postgresqlGroup}:postgresql:$postgresqlVersion")
    implementation("${edcGroup}:control-plane-sql:$edcVersion")

	implementation("${edcGroup}:control-plane-core:${edcVersion}")
	implementation("${edcGroup}:data-plane-core:${edcVersion}")
    implementation("${edcGroup}:data-plane-client:${edcVersion}")
    implementation("${edcGroup}:data-plane-selector-client:${edcVersion}")
    implementation("${edcGroup}:data-plane-selector-core:${edcVersion}")
    implementation("${edcGroup}:transfer-data-plane:${edcVersion}")
	implementation("${edcGroup}:contract-spi:${edcVersion}")
	implementation("${edcGroup}:policy-model:${edcVersion}")
	implementation("${edcGroup}:policy-spi:${edcVersion}")
	implementation("${edcGroup}:core-spi:${edcVersion}")
    implementation("${ionosGroup}:core-ionos-s3:${ionosVersion}")
    implementation("${ionosGroup}:data-plane-ionos-s3:${ionosVersion}")
}