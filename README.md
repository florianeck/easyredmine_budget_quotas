# BudgetQuotas for EasyRedmine

... coming soon

Activities/ProjectSettings - Werden verwendet um zu definierten ob ein timeEntry bieget oder quota bereitstellt
    custom_fields :budget, :kontingent, :open_budget (s. invoice_helper, Kosten)



TimeEntries custom fields
    :valid_from (s. invoice helper, faktura_datum), :valid_to, :is_kontingent

Neue Aktivität:
    Budget, Kontingent (als zuweisung zum Time Entry)
    mit Customfield ob Budget oder Kontingent aufgestockt wird

Permission: Darf Budget, Kontingent anlegen ja nein



TimeEntry:
	- entweder generiert Budget oder Kontingent (mit valid_from/valid_to)
	- oder nutzt Budget/Kontingent

- Dropdown: Is quote, Is budget, Direct

- Bei Eintragen Eines budget/oder Quote-Time-Entry wird abgespeichert aus welchem Budget/quota die Daten kommen (TimeEntryId und name)


Kontingente dürfen Immer genutzt werden








## Info

This Plugin was created by Florian Eck ([EL Digital Solutions](http://www.el-digital.de)) for [akquinet finance & controlling GmbH](http://www.akquinet.de/).

It is licensed under GNU GENERAL PUBLIC LICENSE.

It has been tested with EasyRedmine, but should also work for regular Redmine installations. If you find any bugs, please file an issue or create a PR.
