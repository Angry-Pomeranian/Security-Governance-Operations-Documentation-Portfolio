# Module 2: Compute in the cloud.md

In this module, you will learn about Amazon Elastic Compute Cloud (Amazon EC2) instance types, pricing, and 
related services.

In this module, you will learn how to:
•Describe Amazon Elastic Compute Cloud (Amazon EC2) benefits
• Identify the Amazon EC2 instance types
• Differentiate among Amazon EC2 billing options 
• Summarize Amazon EC2 Auto Scaling benefits
• Summarize Elastic Load Balancing benefits
• Provide examples of Elastic Load Balancing uses
• Describe differences between Amazon Simple Notification Service (Amazon SNS) and Amazon Simple Queue 
Service (Amazon SQS)
• Summarize additional AWS compute options

Topics:
• Topic A: Amazon Elastic Compute Cloud (Amazon EC2)
• Topic B: Amazon EC2 instance types
• Topic C: Amazon EC2 pricing
• Topic D: Amazon EC2 Auto Scaling
• Topic E: Elastic Load Balancing
• Topic F: AWS messaging services
• Topic G: Serverless compute services
• Topic H: AWS container services

-----
# client-server model
<img width="456" height="266" alt="image" src="https://github.com/user-attachments/assets/2379a522-d3ab-465a-8edc-08295cb28002" />

To understand how computing works in the cloud, think about the client-server model introduced in the previous module. Companies use the client-server model to deliver products, resources, and data to their end users. This process is powered by computer servers that host applications and provide the compute power that businesses need.

In a coffee shop, a customer makes a request, and then, a barista fulfills the customer’s request. Think of a barista as a virtual server that fulfills requests. A barista can fulfill requests by providing customers with items such as coffee, tea, or pastries. A virtual server can fulfill requests by providing a client with items such as videos, photos, or static webpages.

In AWS, you can use the Amazon EC2 service to run virtual servers. 

-----
# Topic A: Amazon Elastic Compute Cloud (Amazon EC2)
<img width="97" height="97" alt="image" src="https://github.com/user-attachments/assets/c365e92d-ef6d-4c7d-a886-664f880ecd68" />

Amazon EC2:
• Use secure, resizable compute capacity
• Boot server instances in minutes
• Pay only for what you use

Amazon  EC2 provides secure, resizable compute capacity in the cloud as Amazon EC2 instances.
Imagine that you are responsible for the architecture of your company&apos;s resources and must support new 
websites. 

With traditional on -premises resources, you would:

1. Spend money upfront to purchase hardware.
2. Wait for the servers to be delivered to you.
3. Install the servers in your physical data center.
4.Make all the necessary configurations. By comparison, with an Amazon EC2 instance, you would use a virtual server to run applications in the AWS Cloud.

You could:
• Provision and launch an Amazon EC2 instance within minutes
• Stop using it when you finish running a workload
• Pay only for the compute time you use when an instance is running, not when it is stopped or shut down
• Save costs by paying only for server capacity that you need or want

Here is a quick summary of how Amazon EC2 works. 

First, you launch an instance. To do this,you choose a template with basic configurations for your instance. 
These configurations include the operating system, application server, or applications. You also choose the instance type, which is the specific hardware configuration of your instance.
As you prepare to launch an instance, youspecify security settings to control the network traffic that can flow in and out of your instance. Later in this course, you will explore Amazon EC2 security features in greater detail.
Next, connect to the instance. You can connect to the instance in several ways. Your programs and applications have multiple methods to connect directly to the instance and exchange data. Users can also connect to the instance by logging in and accessing the computer desktop.
After you connect to the instance, you can use it. You can run commands to install software, add storage, copy and organize files, and more.

-----
Topic B: Amazon EC2 instance types

Amazon 
EC2 offers several instance types. This section focuses on what an instance type is and explores the 
various instance types that are available in Amazon EC2.

<img width="297" height="170" alt="image" src="https://github.com/user-attachments/assets/61186714-99c6-4a9c-be17-23ceeb65b63d" />

Example: 
In a coffee shop, suppose that there is only one employee who does everything –makes coffee, processes transactions at the register, orders supplies, and so on. At each phase in the process, the customer ends up waiting. 
This would not be the most efficient use of resources or provide the best customer experience. Having several employees performing the same taskswould also not be efficient.

Different employees have different strengths, such as designing creative latte art, quickly completing payment transactions, or tracking inventory. To keep the coffee shop running efficiently, you could let your employees specialize and work in their areas of strength.
Now, think of the coffee shop employees as different types of Amazon EC2 instances. You can launch Amazon EC2instances in your AWS environment to complete different tasks.
AWS provides a broad choice of instances. They can be general purpose or optimized for specific needs, such as high performancecomputing, big data, storage, and analytics. 

-----
# Amazon EC2 instance types (1 of 2)

General purpose:
• Balances compute, memory, and networking resources
• Suitable for a broad range of workloads

Compute optimized:
• Offers high-performance processors
• Ideal for compute-intensive applications and batch processing workloads

Memory optimized:
• Delivers fast performance for  memory-intensive 
workloads
• Well suited for high-performance databases

When choosing an instance type, consider the specific needs of your workloads and applications. This might 
include requirements for compute, memory, or storage capabilities. 

General purpose instances provide a balance of compute, memory, and networking resources. They can be used for a variety of workloads, such as application servers, gaming servers, backend servers for enterprise  applications, and small and medium databases.Suppose that you have an application in which the resource needs for compute, memory, and networking are  roughly equivalent. You might consider running it on a general purpose instance because the application does not require optimization in any single resource area. Compute optimized instances are ideal for compute - bound applications that benefit from high - performance processors. Like general purpose instances, compute optimized instances can be used for workloads such as web, application, and gaming servers. However, the difference is that compute optimized applications are ideal for high -performance web servers, compute - intensive applications servers, and  dedicated gaming servers. Compute optimized instances can also be used for batch processing workloads that require many transactions to be processed in a single group.
Memory optimized instances are designed to deliver fast performance for workloads that process large datasets in memory. In computing, memory is a temporary storage area. It holds all the data and instructions that a central processing unit (CPU) needs to be able to complete actions. Before a computer program or application can run, it is loaded from storage into memory. This preloading process gives the CPU direct access  to the computer program. Suppose that you have a workload that requires large amounts of data to be preloaded before an application is  run. This might be a high-performance database or a workload that involves performing real-time processing of big unstructured data. In these types of use cases, consider using a memory optimized instance. Memory  optimized instances allow you to run workloads with high memory needs and receive great performance. 

# Amazon EC2 instance types (2 of 2)

Accelerated computing:
• Uses hardware accelerators to expedite data processing
• Ideal for application streaming and graphics workloads

Storage optimized:
• Offers low latency and high input/output operations per second (IOPS)
• Suitable for workloads such as distributed file systems and data warehousing applications

Accelerated computing instances use hardware accelerators, or coprocessors, to perform some functions more Efficiently than is possible in software running on CPUs. Examples of these functions include floating point number calculations, graphics processing, and data pattern matching.
In computing, a hardware accelerator is a component that can expedite data processing. Accelerated computing instances are ideal for workloads such as graphics applications, game streaming, and application streaming.
Storage optimized instances are designed for workloads that require high, sequential read and write access to large datasets on local storage. Examples of workloads suitable for storage optimized instances include distributed file systems, data warehousing applications, and high-frequency online transaction processing (OLTP) systems.
In computing, input/output operations per second (IOPS) is a metric that measures the performance of a storage device. It indicates how many different input or output operations a device can perform in one second. 
Storage optimized instances are designed to deliver tens of thousands of low -latency, random IOPS to applications. 

You can think of input operations as data that is put into a system, such as records that are entered into a database. Output operations are data that is generated by a server. 
An example of output might be the analytics that are performed on the records in a database. 
If you have an application that has a high IOPS requirement, a storage optimized instance can potentially provide improved performance over other instance types that are not optimized for this kind of use case.

Reference 
• For more information about Amazon EC2 instance types, review “Amazon EC2 Instance Types” at: https://aws.amazon.com/ec2/instance-types/


<img width="295" height="169" alt="image" src="https://github.com/user-attachments/assets/d9a297ba-5e8e-437e-be43-30d5a92b59c9" />

--------
# Topic C: Amazon EC2 pricing

This section describes the Amazon EC2 pricing. Additional AWS pricing tools and services are explained later in this course.

Amazon EC2 instance pricing options:

On-demand:
•No upfront costs or minimum contracts
•Ideal for short-term, irregular workloads

Spot:
• Ideal for workloads with flexible start and end times
• Offers savings over On- Demand price

Reserved:
•Provides a billing discount over On-Demand pricing
• Requires a 1-year or 3-year term commitment

Compute Savings Plan:
• Offer up to 66% savings over On-Demand costs for a consistent amount of compute usage
• Require a 1-year or 3-year term commitment

Dedicated Instance:
• An EC2 instance that runs in a VPC on  hardware for a single customer
• Higher cost compared to standard Amazon EC2 instances

Dedicated Host:
• A physical server with EC2 instance capacity for a single customer
• Most expensive Amazon EC2 option

With Amazon EC2, you pay only for the compute time that you use. Amazon EC2 offers a variety of pricing options for different use cases. 

In the coffee shop example, suppose that the owners are experimenting with a new application that is still in the development and testing phases. The application does not yet need to run for long periods of time. 
However, when the application does run, it must do so without interruption so its performance can be accurately assessed. 

**On-Demand Instances**are an excellent option to use for this type of short-term, irregular workload that cannot be interrupted. No upfront costs or minimum contracts apply. The instances run continuously until you stop them, and you pay for only the compute time you use. 
Sample use cases for On-Demand Instances include developing and testing applications, and running applications that have unpredictable usage patterns. On-Demand Instances are not recommended for workloads that last a year or longer, because these workloads can experience greater cost savings through the use of Reserved Instances.

The owners of the coffee shop might also use an Amazon EC2 instance for their data processing, such as a batch workload that aggregates and analyzes customer survey data. Compared to other types of batch workloads in the coffee shop, such as daily financial processing, the survey data processing is not mission-critical. 
To save costs, the coffee shop owners decide to use a Spot Instance for their survey data processing. Spot Instances are ideal for these types of workloads with flexible start and end times, or that can withstand interruptions. 

**Spot Instances** use unused EC2 computing capacity and offer you cost savings at up to 90 percent of On-Demand prices. 
Suppose that you have a background processing job that can start and stop as needed (such as the customer survey data processing job). You want to start and stop the processing job without affecting the overall operations of your business. If you make a Spot request and Amazon EC2 capacity is available, your Spot Instance launches. 
However, if you make a Spot request and Amazon EC2 capacity is unavailable, the request is not successful until capacity becomes available. The unavailable capacity might delay the launch of your background processing job.

After you have launched a Spot Instance, if capacity is no longer available or demand for Spot Instances increases, your instance might be interrupted. This might not pose any issues for your background processing job. However, in the earlier example of developing and testing applications, you would most likely want to avoid unexpected interruptions. Therefore, you should choose a different EC2 instance type that is more ideal for those tasks.

Suppose that the coffee shop owners have an application that will run continuously for at least a year. An example of this might be the main application that customers use for mobile ordering. The owners don’t think that Spot Instances would be a good fit because of possible interruptions. They also considered On-Demand Instances, but the estimated price seems high for what they would pay for a year of compute time. 
This is an example of when to consider Reserved Instances. 

**Reserved Instances** are a billing discount that is applied to the use of On-Demand Instances in your account. 
You can purchase Standard Reserved and Convertible Reserved Instances for a 1-year or 3-year term, and Scheduled Reserved Instances for a 1-year term. 
You realize greater cost savings with the 3-year option. 
At the end of a Reserved Instance term, you can continue using the EC2 instance without interruption. 
However, you are charged On-Demand rates until you shut downthe instance or purchase a new Reserved Instance that matches the instance attributes (instance type, Region, tenancy, and platform).

Next, suppose that the coffee shop owners want to save costs on their EC2 compute usage, but they want to have even more flexibility than what is possible with Reserved Instances. In this situation, they might consider  **Compute Savings Plans**.

AWS offers Savings Plans for several compute services, including Amazon EC2. Amazon EC2 Savings Plans can help you reduce your compute costs by committing to a consistent amount of compute usage for a 1-year or 3-year term. This results in savings of up to 66 percent over On-Demand costs.Any usage up to the commitment is charged at the discounted plan rate (for example, $10 an hour). Any usage beyond the commitment is charged at regular On-Demand rates.

Later in this course, you will review AWS Cost Explorer, a tool that can help you visualize, understand, and manage your AWS costs and usage over time. If you are considering your options for Savings Plans, AWS Cost 
Explorer can analyze your EC2 usage over the past 7, 30, and 60 days. AWS Cost Explorer also provides customized recommendations for Savings Plans. These recommendations estimate how much you could save on your monthly EC2 costs, based on previous EC2 usage and the hourly commitment amount in a 1-year or 3-year plan.

Now, suppose that there is a healthcare clinic located next to the coffee shop. The clinic must meet specific compliance and regulatory requirements. For example, it must ensure that its data doesn’t reside on the same data servers that are used by other companies. Dedicated Instances and Dedicated Hosts are two options to consider for these types of use cases.

• **Dedicated Instances** are EC2 instances that run in a virtual private cloud (VPC) on hardware that is dedicated to a single customer. Dedicated Instances have a higher cost compared to standard Amazon EC2 instances. Dedicated Instances run uninterrupted, and you pay for only the compute time you use. However, you also have the option to reduce your costs by purchasing Reserved Dedicated Instances.
• **Dedicated Hosts** are physical servers with EC2 instance capacity that is fully dedicated to your use. You can use your existing per-socket, per-core, or per-VM software licenses to help maintain license compliance. You can purchase Dedicated Hosts on-demand or reserved. Of all the EC2 options covered, Dedicated Hosts are the most expensive.


# What is the difference between Compute Savings Plans and Spot Instances?
- **Compute Savings Plans** are ideal for workloads that involve a consistent amount of compute usage over a 1-year or 3-year term. With Compute Savings Plans, you can reduce your compute costs by up to 72 percent over On-Demand costs.
- **Spot Instances** are ideal for workloads with flexible start and end times, or that can withstand interruptions. Unlike Amazon EC2 Savings Plans, Spot Instances do not require contracts or a commitment to a consistent amount of compute usage

--------------
# Topic D: Amazon EC2 Auto Scaling

# Manual scaling - Low vs High demand
<img width="393" height="219" alt="image" src="https://github.com/user-attachments/assets/0a450687-75c0-4220-9c05-4cf52dae25cc" />

Suppose that in the coffee shop, a barista is assigned to work at the register. 
When the coffee shop is in a period of low demand, the barista can readily manage their workload.
Now, suppose that the coffee shop is open during its busiest season of the year. Because of the increased demand, the barista feels overwhelmed by the increased workload. 

The barista asks the manager for additional assistance, and the manager assigns another barista to help. 
When the workload decreases, the second barista can stop working at the register. 
This process is an example of  manual scaling.
Scalability involves beginning with only the resources you need and designing your architecture to scale automatically in and out in response to changing demands. 
As a result, you pay for only the resources you use. 

You don’t have to worry about a lack of computing capacity to meet your customers’ needs.

**What if you want scaling to happen automatically?** 
The AWS service that provides this functionality for Amazon EC2 instances is **Amazon EC2 Auto Scaling**.

# Amazon EC2 Auto Scaling

• Scale capacity as computing requirements change
• Use dynamic scaling and predictive scaling

Have you ever tried to access a website that wouldn’t load and it kept timing out? 
The website might have been receiving more requests than it was able to handle. 
This is similar to the experience of waiting in a long line at a coffee shop, when there is only one barista present to take orders from customers.

Amazon EC2 Auto Scaling can help you automatically add or remove Amazon EC2 instances in response to changing application demand. 
By automatically scaling your instances in and out as needed, you can maintain a greater sense of application availability.
With Amazon EC2 Auto Scaling, you can use two approaches –dynamic scaling and predictive scaling. 

*Dynamic scaling* responds to changing demand. 
*Predictive scaling* automatically schedules the right number of Amazon EC2 instances based on predicted demand. 
To scale faster, you can use dynamic scaling and predictive scaling together.

In the cloud, computing power is a programmatic resource, so you can take a more flexible approach to the issue of scaling. 
By adding Amazon EC2 Auto Scaling to an application, you can add new instances to the application when necessary and remove them when no longer needed.
Suppose that you are preparing to run an application on Amazon EC2 instances. 
When configuring the size of your Auto Scaling group, you might set the minimum number of Amazon EC2 instances at one. This means that at all times, at least one Amazon EC2 instance must be running.

When you create an Auto Scaling group, you can set the minimum number of Amazon EC2 instances. 
The *minimum capacity* is the number of Amazon EC2 instances that launch immediately after you create the Auto Scaling group. 
In this example, the Auto Scaling group has a minimum capacity of one Amazon EC2 instance.

Next, you can set the desired capacity at two Amazon EC2 instances, even though your application needs a minimum of a single Amazon EC2 instance to run. 
If you do not specify the desired number of Amazon EC2 instances in an Auto Scaling group, the desired capacity defaults to your minimum capacity.
