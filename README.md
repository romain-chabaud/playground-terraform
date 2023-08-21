# Terraform training exercice

## Objectives

This is a simple Terraform practice exercice creating a simple Cloud Run service accessing a Postgres instance.

The database instance password is generated, then saved in a Secret Manager.

## Requirement

Having Terraform installed

## How to create the infrastructure

### Required variables

* ``project_id``
* ``region``

### Optional variables

* ``db_password_length``: the length of the database generated password. The minimal length is 8, meaning if you give a value inferior to that, your password will have a length of 8 characters.

### Load the packages

``` terraform init ```

### Create

``` terraform apply ```
