# Even if you’re part of a conscientious development team that tirelessly pushes back on profitless features, it’s inevitable that you’ll find yourself working on the dreaded behemoth code base.

# A good rule of thumb for measuring application size and complexity is the number of models it contains. We’ve seen applications from 2 to 200 models, and we’ve learned from experience that the maintenance costs never scale linearly with the size of the application. Instead, developers end up drudging through 20-minute test runs, thousand-line models, and other issues as an application grows.

# Solution: Divide into Confederated Applications

# Reducing the size of the code base is a crucial goal during development. Doing so without reducing the feature set can be a difficult task. One solution that can often work quite well is to split the code into entirely separate applications.

# You have a Ticket model, a TicketsController model for managing tickets, an Email model for accepting incoming emails via SMTP, and an EmailsController model for the administrator to inspect those email messages. You can accept incoming emails because you’ve configured a local SMTP server to “deliver” the emails to a Ruby script, which, in turn, creates Email records in the application. The Email model then finds and updates the Ticket record, possibly adding the body as a new comment.

# bad

ticket CRUD
- Tickets controller

internet
- sends email
- LocalMail server receives
- creates email
- updates ticket

in the monolith you have [tickets_controller, local_mail_controller]

# Even though the email functionality must be able to trigger an update of the Ticket model, it’s possible to extract this area of the application into a separate application altogether. Figure 5.2 shows this new system.

# Here, EmailsController, the Email model, and the SMTP mechanism are moved into another application. This application could reside on another server altogether, allowing it to be maintained and scaled separately from the main application.

# The major difference in this new system is that instead of accessing the database to find and modify the ticket associated with that email message, the Email model does an HTTP Post to the main application. (A likely entry point would be /tickets/update_via_email.) The main application then finds and updates the ticket on its own. All the logic for receiving, parsing, and monitoring email deliveries would be contained in that separate application, significantly reducing the complexity of the ticket tracker.

# better

Ticket service <= HTTP post <= Email service

# best (decouple for resiliency) create a job queue so in case the service is down, there are no downtimes

Ticket service <= HTTP post <= email worker <= queue <= email <= Email service

# if every application is using HTTP to connect to every other application, downtime in any one of them can cause the whole engine to grind to a halt.

# To protect against this grinding to a halt, it’s necessary to decouple the various applications from each other via queues and buffers. For the application we’ve been discussing, you can use a queue system (possibly using Resque) to solve the problem nicely
