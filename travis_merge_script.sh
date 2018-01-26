if [ "$TRAVIS_BRANCH" != "dev" ]; then 
    exit 0;
fi

export GIT_COMMITTER_EMAIL="allanbrados@gmail.com"
export GIT_COMMITTER_NAME="Allan David"

git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* || exit
git fetch --all || exit

git stash

git checkout master || exit
git merge --no-ff "$TRAVIS_COMMIT" || exit

git stash pop

OLD_MSG=$(git log --format=%B -n1)
git commit --amend -am "$OLD_MSG - Formatted with Elixir"

git push https://${GITHUB_TOKEN}@github.com/allmonty/tech-challenge.git