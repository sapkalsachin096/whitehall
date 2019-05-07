matthew_purves = Person.where(surname: 'Purves', forename: 'Matthew').first
role = Role.where(name: 'Deputy Director, Schools').first
role_appt = matthew_purves.role_appointments.where(role_id: role.id).first

EditionRoleAppointment.where(role_appointment: role_appt).delete_all

role_appt.delete
role.delete
matthew_purves.delete

Services.publishing_api.patch_links('aa78b82f-e834-4c17-a9b9-66876fe46296', links: {'speaker' => []})
