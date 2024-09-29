# Diffnosis
Self-diagnosis by only searching up symptoms on the Internet is notoriously unreliable and many doctors advise against doing so.

With Diffnosis, you can interact with a virtual health consultant and conduct your own differential diagnosis, taking into account your medical information for a more complete analysis of possible conditions. Diffnosis also searches through WHO and the CDC to determine whether or not you are at risk of infection due to travel, both domestically and internationally. Diffnosis also utilizes the Groq API to analyze an image using the llama vision model to analyze any epidermal abnormalities you may be concerned about.

The app interface itself is built in Swift on Xcode, and MagicLoops was used to incorporate generative UI to speed up the development process. Groq API was implemented through Python to enable the health consultant, travel risk, and image processing features. The WHO and CDC outbreak reports were scraped using the Scrapy library in Python.

Currently, Diffnosis utilizes Common Crawl data and information from the Mayo Clinic. In the future, Diffnosis will hopefully be able to be trained with more advanced medical literature to account for rarer cases of different conditions. The image processing model can also be trained to look for more conditions via supervised learning.
