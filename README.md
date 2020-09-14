# redmine_spent_time
<b>Version >= 4.0.0 for Redmine 4.x</b>

Versions for Redmine < 4.0 are not supported anymore.

This is a [Redmine's](https://www.redmine.org) plugin which allow users to add spent time entries for issues they have worked on.
It gives users a comfortable form to do queries about their spent time on projects, along with a little form
to submit new entries. Of course also it's possible to delete entries and to modify existing ones.

From this functionality a user will be able to add time entries to assigned issues or to issues which he
has already spent some time but are not assigned to him.

## Installation

1. Go to your redmine root path/plugins.
2. At the command line type
    git clone https://github.com/eyp/redmine_spent_time.git
3. Restart your Redmine web servers (e.g. mongrel, thin, mod_rails).
4. Login and configure the plugin (see Permissions section.)
5. Click the 'Spent time' link in the top left menu.

## Permissions

There are some permissions which can be set up for every role from the Administration -> Roles and permissions.

* Time tracking -> 'View spent time': Activated by default, it allows the user to go to this plugin's main page.
* Project -> 'View others spent time': Deactivated by default, it allows the user to view the spent time of other members of the projects he is member of.
* Project -> 'View every project spent time': Deactivated by default, it allows to view the spent time of everyone.

## Usage

It's very easy to use, click the 'Spent time' link in the top left menu, from there you will be able to do queries and add entries. 
After doing a query, if there are time entries in the result, you will be able to modify or delete them.

## Languages

* Catalonian, English, French, German, Hungarian, Italian, Japanese, Polish, Portuguese, Russian, Simplified Chinese & Spanish.
<b>HELP on translations</b>: Only English, Italian, Japansese & Spanish are complete, others need some literals to translate.

## Code contributors

* @lauer (Jesper Grann Laursen), @burci (Peter Buri), @mjanser (Martin Janser)
* @pedrosnk (Pedro Medeiros), @krewetka (Ania Krawet), @mficzel (Martin Ficzel)
* @nick7ikin, @Weptun, @alexandermeindl (Alexander Meindl)

## Translators

* General help on translations: @cforce (Terence Miller)
* German: @mjanser (Martin Janser), @alexandermeindl (Alexander Meindl)
* Hungarian: @burci (Peter Buri)
* Italian: @maramazza (Matteo Mazzoli), @R-i-c-k-y
* Japanese: Hajime (@momibun926)
* Polish: @krewetka (Ania Krawet), @dgutkowsky
* Portuguese: @heslei (Heslei Silva)
* Russian: @ilya-yurtaev (Ilya Yurtaev)
* Simplified Chinese: @archonwang (Steven W.)
* Czech: @j123b567 (Jan Breuer)

## License

This plugin is licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

## Project help

If you need help you can create an issue in the [GitHub Issues tracker](https://github.com/eyp/redmine_spent_time/issues).

## Release notes
<b>4.1.0 - 2020-09-14</b>
* Fix: #116 invalid user creating a time entry on Redmine 4.1.X. Tested on Redmine 4.1.1/Ruby 2.6.6/Rails 5.2.3.

<b>4.0.0 - 2019-06-17</b>
* #114 Tested on Redmine 4.0.4/Rails 5.2.3.
* #98 Changed date fields to be able to use browser calendars instead of simply text fields.

<b>3.1.2 - 2015-10-01</b>
* #77 Refactored routes.rb and fixed projects combo box (@alexandermeindl).

<b>3.1.0 - 2015-09-24</b>
* Tested on Redmine 3.1.1, Rails 4.2, Ruby 2.1.6
* Fix: #73 Closed projects are not included in report
* Fix: #74 Time displays 0.00 when time entry is not linked to an issue
* Fix: #75 Incomplete issues list in combo box

<b>2.6.7 - 2015-09-24</b>
* Fix: #73 Closed projects are not included in report

<b>3.0.2 - 2015-05-21</b>
* Fix: #72 User field is no longer alphabetically ordered

<b>3.0.0 - 2015-04-09</b>
* Request: #68 Updated in order to work in Redmine 3.0 under Rails 4.2
* Removed: #69 Updating spent times in line with best_in_place plugin doesn't work in Redmine 3 (Rails 4.2)

<b>2.6.6 - 2014-10-16</b>
* Fix: #67 View every projects spent time doesn't work as expected

<b>2.6.5 - 2014-03-31</b>
* Translate: #60 Completed Italian translation by @R-i-c-k-y

<b>2.6.4 - 2014-03-17</b>
* Translate: #59 Added Japanese translation by Hajime (@momibun926)

<b>2.6.3 - 2014-03-03</b>
* Fix: #57 undefined method `estimated_hours'
* Enhancement: #58 German translation completed

<b>2.6.2 - 2014-02-26</b>
* Fix: #53 undefined local variable or method `project_id'...
* Fix: #54 Problem with permission
* Enhancement: #56 Added total estimated time to report

<b>2.6.1 - 2014-02-20</b>
* Fix: #50 Sorting is not working
* Fix: #51 Interval's filter not working
* Fix: #52 Issue column content is not being wrapped up

<b>2.6.0 - 2014-02-10</b>
* Allows to insert time entries on weekends, and show the hours.
* Custom fields on time entries insertion.
* Notify when time entry is created or updated.
* Only shows active projects by default (@Weptun).
* Check permissions before create entries (@nick7ikin).
* More errors controls (@nick7ikin).
