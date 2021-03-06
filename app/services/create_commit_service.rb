class CreateCommitService
  def execute(project, params)
    before_sha = params[:before]
    sha = params[:after]
    ref = params[:ref]

    if ref && ref.include?('refs/heads/')
      ref = ref.scan(/heads\/(.*)$/).flatten[0]
    end

    # Skip branch removal
    if sha == Git::BLANK_SHA
      return false
    end

    # Dont create commit if we already have one
    if commit_exists?(project, sha)
      return false
    end

    if project.skip_ref?(ref)
      return false
    end

    data = {
      ref: ref,
      sha: sha,
      before_sha: before_sha,
      push_data: {
        before: before_sha,
        after: sha,
        ref: ref,
        user_name: params[:user_name],
        repository: params[:repository],
        commits: params[:commits],
        total_commits_count: params[:total_commits_count]
      }
    }

    commit = project.commits.create(data)
    commit.create_builds
    commit
  end

  def commit_exists?(project, sha)
    project.commits.where(sha: sha).any?
  end
end
