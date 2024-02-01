plugins {
    id("java")
    id("application")
    id("com.github.johnrengelman.shadow") version "7.1.2"
}
val edcGroup: String by project
val edcVersion: String by project
val ionosGroup: String by project
val ionosVersion: String by project
val nextcloudVersion: String by project
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

dependencies {
    implementation("${edcGroup}:boot:${edcVersion}")
    implementation("${edcGroup}:control-plane-core:${edcVersion}")
    implementation("${edcGroup}:control-plane-api:${edcVersion}")
    implementation("${edcGroup}:control-plane-api-client:${edcVersion}")
    implementation("${edcGroup}:api-observability:${edcVersion}")
    implementation("${edcGroup}:configuration-filesystem:${edcVersion}")

    implementation("${edcGroup}:auth-tokenbased:${edcVersion}")
    implementation("${edcGroup}:management-api:${edcVersion}")
    implementation("${edcGroup}:vault-hashicorp:${edcVersion}")
    implementation("${edcGroup}:iam-mock:${edcVersion}")
    implementation("${edcGroup}:dsp:${edcVersion}")
    //file-transfer
    implementation("${edcGroup}:data-plane-core:${edcVersion}")
    implementation("${ionosGroup}:dataplane-ionos-nextcloud:${nextcloudVersion}")
    implementation("${edcGroup}:data-plane-client:${edcVersion}")
    implementation("${edcGroup}:data-plane-selector-client:${edcVersion}")
    implementation("${edcGroup}:data-plane-selector-core:${edcVersion}")
    implementation("${edcGroup}:transfer-data-plane:${edcVersion}")
    implementation("${edcGroup}:data-plane-http:${edcVersion}")
    implementation("${edcGroup}:http:${edcVersion}")

    testImplementation(platform("org.junit:junit-bom:5.9.1"))
    testImplementation("org.junit.jupiter:junit-jupiter")
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
    archiveFileName.set("connector.jar")
}