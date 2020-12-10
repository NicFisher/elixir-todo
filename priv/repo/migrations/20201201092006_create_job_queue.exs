defmodule Todo.Repo.Migrations.CreateJobQueue do
  use Ecto.Migration

  @ecto_job_version 3

  def up do
    EctoJob.Migrations.Install.up()
    EctoJob.Migrations.CreateJobTable.up("jobs", version: @ecto_job_version)
  end

  def down do
    EctoJob.Migrations.CreateJobTable.down("jobs")
    EctoJob.Migrations.Install.down()
  end
end
