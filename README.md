loadr: Cleaner R workspaces
-----------------------------------------------
In a large, complex R analysis, I often find myself with dozens of resource data objects that I use as a reference for my computation. These are usually some kind of large dataset that I read into R and then use as reference data. As an example, I have a file with a big matrix with values from chromatin accessibility for 120 different cell-types across about a million different genomic regions (so, a 120-by-1 million matrix). I read this into my R sessions occasionally when I want to see, for example, how a new set of regions looks across that data resource. I'm not really changing the resource data, I'm just using it as a reference. I may load dozens of these kinds of resources into a single R session, and I want to re-use them across multiple scripts and multiple sessions, so I find myself reading them in a lot. I also start writing functions around these kinds of resources.

Given this complexity, sometimes it gets confusing for me to keep track of all the variables I keep in my primary R workspace, so I started to investigate how I could use R environments to declutter things. I discovered that I could load these kinds of "shared data reference" sets into a separate R environment, let's call it SV for "Shared Variables" -- and then they don't clutter my primary R workspace and I can still access them with SV$variable. This cleaned things up a bit for me and so I've developed a series of functions that make it really easy to interact with reference data like this kept in its own separate environment. That's what loadr is.





