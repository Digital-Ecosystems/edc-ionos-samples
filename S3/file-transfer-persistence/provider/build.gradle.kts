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
 *       Fraunhofer Institute for Software and Systems Engineering - added dependencies
 *       ZF Friedrichshafen AG - add dependency
 *
 */

plugins {
    `java-library`
    id("application")
    id("com.github.johnrengelman.shadow") version "7.1.2"
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
   
	  gradlePluginPortal()
}
val javaVersion: String by project
val faaastVersion: String by project
val edcGroup: String by project
val postgresqlGroup: String by project
val postgresqlVersion: String by project
val edcVersion: String by project
val ionosGroup: String by project
val ionosVersion: String by project
val okHttpVersion: String by project
val rsApi: String by project
val metaModelVersion: String by project

dependencies {

	
    implementation(project(":S3:file-transfer-persistence:transfer-file"))
	

	
}

application {
    mainClass.set("org.eclipse.edc.boot.system.runtime.BaseRuntime")
}
tasks.shadowJar {
   isZip64 = true  
}

tasks.withType<com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar> {
    exclude("**/pom.properties", "**/pom.xm")
    mergeServiceFiles()
    archiveFileName.set("dataspace-connector.jar")
}
