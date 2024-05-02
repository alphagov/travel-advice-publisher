if User.where(name: "Test user").blank?
  gds_organisation_id = "af07d5a5-df63-4ddc-9383-6a666845ebe9"

  User.create!(
    name: "Test user",
    permissions: ["signin", "GDS Editor"],
    organisation_content_id: gds_organisation_id,
  )

  if User.where(name: "Scheduled Publishing Robot", uid: "scheduled_publishing_robot").blank?
    User.create!(
      name: "Scheduled Publishing Robot",
      uid: "scheduled_publishing_robot",
    )
  end
end
