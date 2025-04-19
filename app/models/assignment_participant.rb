# frozen_string_literal: true

class AssignmentParticipant < Participant
  belongs_to  :assignment, class_name: 'Assignment', foreign_key: 'assignment_id'
  belongs_to :user
  validates :handle, presence: true

  def set_handle
    self.handle = if user.handle.nil? || (user.handle == '')
                    user.name
                  elsif Participant.exists?(assignment_id: assignment.id, handle: user.handle)
                    user.name
                  else
                    user.handle
                  end
    self.save
  end

  # returns the reviewer of the assignment. Checks the team_reviewing_enabled flag to
  # determine whether this AssignmentParticipant or their team is the reviewer
  def get_reviewer
    return team if assignment.team_reviewing_enabled

    self
  end

  #E2479
  def team
    AssignmentTeam.team(self)
  end

  def team_user
    TeamsUser.where(team_id: team.id, user_id: user_id).first if team
  end
end
