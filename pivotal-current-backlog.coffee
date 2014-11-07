# Pivotal Tracker Project Backlog
# Author: Mike Mclaren <mike.mclaren@sq1.com>

# Your Pivotal Tracker API token.
token: 'TOKEN'

# Your Pivotal Tracker Project ID.
projectId: 1

# What you want to display as the header of the box.
projectName: "Project Name"

# Five minute default.
refreshFrequency: 5 * 60 * 1000

command: ""

# The base template things get inserted into.
render: () -> """
  <h1>#{@projectName}</h1>
  <div class="pivotal-tracker-list">
    <div class="wrapper">
      <ul>

      </ul>
    </div>
  </div>
"""

style: """
  bottom: 30px
  right: 30px
  width: 500px
  font-family: Helvetica Neue
  font-weight: 200
  color: #FFF
  font-size: 18px
  background: rgba(0,0,0,0.4)
  padding-left: 20px
  padding-right: 20px
  padding-bottom: 20px

  button + button
    width: 50%

  button
    text-align: right
    font-size: 14px
    height: 23px
    position: relative
    top: -2px

  .deliver-button
    background-color: #FF851B
    border: 0
    color: white
    font-weight: 600

  .finish-button
    background-color: #0074D9
    border: 0
    font-weight: 600

  h1
    margin-bottom: 10px
    margin-top: 10px

  .wrapper
    height: 200px
    overflow-y: scroll

  ul
    margin: 0
    padding: 0
  li
    list-style: none
    padding-top: 5px
    min-height: 25px
    margin-bottom: 5px

    a
      vertical-align: top
      color: white
      text-decoration: none
      display: inline-block
      width: 310px
      margin-left: 10px
      margin-top: 1px

    .status
      vertical-align: top
      text-transform: uppercase
      width: 120px
      display: inline-block
      font-weight: 500
      text-align: right

    .accepted
      color: #2ECC40

    .rejected
      color: #FF4136

    .finished
      color: #0074D9

    .started
      color: #FF851B

    .estimate
      width: 40px
      display: inline-block

      .point
        display: inline-block
        width: 3px
        height: 25px
        background-color: #39CCCC
        margin-right: 2px
"""

update: (output, domEl) ->
  @._fetch().then (output) =>
    if !@content
      @content = $(domEl).find '.wrapper'

    html = """<script type="text/javascript">
      change = function(t) {
        storyId = $(t).attr('data-story-id');
        stateChange = $(t).attr('data-state-change');

        $.ajax({
          url: "https://www.pivotaltracker.com/services/v5/projects/#{@projectId}/stories/"+storyId,
          headers: {
            'X-TrackerToken': '#{@token}'
          },
          type: 'PUT',
          data: {
            "current_state": stateChange
          },
          success: function(data) {
          }
        });
      };
    </script>"""

    for iteration in output
      for story in iteration.stories
        estimate = ''
        for num in [story.estimate..1]
          estimate += "<span class='point'></span>"

        html += """
          <li>
            <span class="estimate">#{estimate}</span>
        """

        if story.current_state is 'accepted'
          html += """
              <span class='status #{story.current_state}'>
                #{story.current_state}
              </span>
          """
        else if story.current_state is 'delivered'
          html += """
              <span class='status'>
                <button class='accept-button pv-button' data-story-id='#{story.id}'>Accept</button>
                <button class='reject-button pv-button' data-story-id='#{story.id}'>Reject</button>
              </span>
          """
        else if story.current_state is 'finished'
          html += """
            <span class='status'>
              <button class='deliver-button pv-button' data-story-id='#{story.id}' data-state-change='delivered' onclick='change(this)'>
                Deliver
              </button>
            </span>
          """
        else if story.current_state is 'started'
          html += """
            <span class='status'>
              <button class='finish-button pv-button' data-story-id='#{story.id}' data-state-change='finished' onclick='change(this)'>
                Finish
              </button>
            </span>
          """
        else if story.current_state is 'unstarted'
          html += """
            <span class='status'>
              <button class='start-button pv-button' data-story-id='#{story.id}' data-state-change='started' onclick='change(this)'>
                Start
              </button>
            </span>
          """

        html += """
            <a href="#{story.url}">#{story.name}</a>
          </li>
        """

    @content.html html

_fetch: () ->
  defer = new $.Deferred

  $.ajax
    url: "https://www.pivotaltracker.com/services/v5/projects/#{@projectId}/iterations?limit=10&scope=current_backlog"
    headers:
      'X-TrackerToken': @token
    success: (data) ->
      defer.resolve data

  return defer.promise()
