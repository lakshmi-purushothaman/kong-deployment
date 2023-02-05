# High level startegy for modernizing a large scale legacy (monolith) application

## High Level Summary

![Stages](/TA1/kubernetes/amazon/EC/States.png)
- Modernisation of a large legacy centralised (monolithic) mission critical application running on HPE NonStop technology developed in a non-modern programming language (COBOL) using messaging middleware (IBM MQ) as the communication back-bone.
- A key part of this modernisation is to migrate this monolithic application from HPE NonStop proprietary platform to a modern platform
    - Firstly to migrate from HPE NonStop proprietary platform (Guardian) to HPE NonStop Linux like platform (OSS)
    - Migrate to a modern commoditised platform involving new technology stack like:
        - Java
        - Event Hub Technology (Kafka)
        - Modern test tools and methods (TDD, BDD)
        - Adoption of DevOps(CI/CD)
        - Containerisation 

## High level target architecture

### Key Considerations/Assumptions

There could be many reasons for the desire to modernize the legacy application; For the purpose of this proposition, key focus would be on:
- Loose Coupling </br>
    - Loose coupling between components/services and infrastructure
    - Independently deployable and scalable
- Build Cloud native applications</br>
    - Event driven microservices
    - Statelessness
    - Circuit Breakers and API Gateways
    - Interaction Redundancy - Retries and other control loops
- Agility in development process, by adopting </br>
    - Devops processes like workflow automation using CI/CD pipelines, test automation
    - Infrastructure automation - Elastic infrastructure, Containers 
    - Support for Polyglot programming

### Architecture Blueprint

By combinining EDA and microservices architecture style, we can achieve non-functional qualities such as performance, scalability, availability, resiliency, and ease of development.

![High Level Architecture](/TA1/kubernetes/amazon/EC/Architecture.png)

### Key architectural considerations
These considerations will act as guide rails to make architectural decisions, which will influence the architecture of the system
- Architectural Patterns </br>
    - Command Query Responsibility Segregation (CQRS)
    - Saga (Orchestration or Choreography)
    - Event Outbox and Inbox - Enables handling distributed transactions and idempotent consumers
    - Dead Letter Queue
    - Service Mesh
    - Event Sourcing
    - Stream Processing
- Technology Stack </br>
    This is the backbone for key architectural qualities (performance, availability, reliability, operating cost, fault-tolerance, and so on) and simplifies development.
    - High availability
        Different availability zones or regions, fault-tolerant, data replication, rolling upgrades
    - Scalability
        Without compromising availability
    - Vendor lock in should be avoided
    - For Event brokers, support for </br>
        - Multiple serialization formats (JSON, Avro)
        - Partitionag and preserving the order of events
    - Low operational cost
    - Polyglot Programming
- Event Modelling </br>
    Define Event Types, Event Schema, Versioning, Establish Serialization format (AVRO, JOSN,..), Define Partitioning strategy, Ordering and Durability
- Deployment Topology </br>
    - Each deployed component should be independently scalable and deployed as cluster to support concurrency and resilience
    - Cluster spanning across multiple AZ's
    - Establish Replication factor
    - Workload Throttling
    - Encryption
- Exception Handling Strategy </br>
    - Exception logging
    - Retry strategy (Number of retries, time between retries)
    - Raising Alerts


### Breaking down the monolith key principles
- Event Storming </br>
    - Flexible workshop format for collabroative exploration of complex business domains to envision new services
    - Enables cross discipline conversations between business, engineers, leaders, UX representatives
    - Explore the business domain by: </br>
        - Building a timeline view of events in a process or system
        - Identify domain events
        - Connect domain events to commands (Trigger or cause of the event)
        - Connect domain events to reactions i.e., Reactions are actions and results following an event
    - Group similar modules (Bounded Contexts), this will help in identifying the domains

![Event Storming](/TA1/kubernetes/amazon/EC/Event-Storming.png)
- Team structure </br>
    If the engineering teams are geographically split, then the team co-located can work on a single service
 - Rate of Delivery </br>
    Grouping services that have a different rate of delivery will cause friction and slowdonw the velocity of delivery
 - Risk Tolerance </br>
    Isolating a critical component service in it's own dedicated deployment unit, would be more appropriate
 - Scalability </br>
    - Separating the service that needs to scale (horizntal or vertical) needs to be separated
    - The insights in terms of topic consumption, resource utilization can also help in identifying the services that needs to be separated</br>

![Microservice Identification](/TA1/kubernetes/amazon/EC/Identifying-Microservices.png) 

     
### Migration strategy

![Migration strategy](/TA1/kubernetes/amazon/EC/Migration-Stage.png)


### Stakeholders Engagement

- Identifying key stakeholders and clear definition of roles
- Establishing Framework and tool implementation 
    - Agreement of tools to be used for demand management, architecture repository (Github, Confluence,..) for diagarms and documents
    - Create example templates
- Setting up Architecture Review Board catchups
    - Establish ARB memebers list and roles
    - Build Enterprise Reference Architecture
    - Establish review process, feedback mechanism and approval process
- Consistent and Continuous engagement with business/product owners


### Expected deliverables and budgets

<<TBD>>
