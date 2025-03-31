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

    // Core
    implementation("${edcGroup}:connector-core:${edcVersion}")
    implementation("${edcGroup}:http:${edcVersion}")
    implementation("${edcGroup}:dsp:${edcVersion}")
    implementation("${edcGroup}:management-api:${edcVersion}")
    implementation("${edcGroup}:api-observability:${edcVersion}")

    implementation("${edcGroup}:configuration-filesystem:${edcVersion}")
    implementation("${edcGroup}:vault-hashicorp:${edcVersion}")
    implementation("${edcGroup}:iam-mock:${edcVersion}")

    // Control Plane
    implementation("${edcGroup}:control-plane-api-client:${edcVersion}")
    implementation("${edcGroup}:control-plane-api:${edcVersion}")
    implementation("${edcGroup}:control-plane-core:${edcVersion}")
    implementation("${edcGroup}:control-api-configuration:${edcVersion}")

    // Data Plane
    implementation("${edcGroup}:data-plane-selector-api:${edcVersion}")
    implementation("${edcGroup}:data-plane-selector-core:${edcVersion}")
    implementation("${edcGroup}:data-plane-self-registration:${edcVersion}")
    implementation("${edcGroup}:data-plane-control-api:${edcVersion}")
    implementation("${edcGroup}:data-plane-public-api-v2:${edcVersion}")
    implementation("${edcGroup}:data-plane-core:${edcVersion}")
    implementation("${edcGroup}:data-plane-http:${edcVersion}")
    implementation("${edcGroup}:transfer-data-plane-signaling:${edcVersion}")



    // Ionos Extensions
    implementation("${ionosGroup}:provision-ionos-s3:${ionosVersion}")
    implementation("${ionosGroup}:data-plane-ionos-s3:${ionosVersion}")
    implementation("${ionosGroup}:core-ionos-s3:${ionosVersion}")
}