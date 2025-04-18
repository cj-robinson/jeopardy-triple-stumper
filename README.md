# Jeopardy Triple Stumpers

Find the story here: [https://cj-robinson.github.io/jeopardy](https://cj-robinson.github.io/jeopardy/)

### Overview/Findings

This project found that Jeopardy games had a higher average number of 'triple stumpers' in recent months, meaning that all three contestants were not able to answer a clue correctly. I interviewed Jeopary experts and contestants to hear about their experiences and perceptions, and used scrollytelling to walk readers through my visualizations. 

### Goals

My original reporting question was based on whether Jeopardy itself had gotten harder. I knew there were a variety of tournaments that recently ran back-to-back that could impact this perception, but I wanted to know how much this imapcted the ways contestants were answering clues. I also wanted to (selfishly) speak to some recent Jeopardy champions about their experiences. 

This was an assignment for our Data Studio class at Columbia Journalism School's Data Journalism program, intended to think about how to create end-to-end data stories about topics of our choosing on deadline.

### Data Collection and Analysis

#### Scraping

I scraped the data from the [J! Archive](https://j-archive.com/), a crowd-sourced website of all Jeopardy games with detailed metadata including guesses, scores and other player attributes. I utilized BeautifulSoup to scrape each season from the aggregated page, then scraped each link from those seasons. I originally wanted to scrape based on game-ids, a identifier from the J! Archive website, but there were not chronological and had issues with parsing a large list of URLS. 

#### Analysis

To clean the data, I needed to filter out any tournaments that may have altered difficulties (college week tournaments are usually a lot easier and invitationals are usually more difficult). I categorized these games based on the 'notes' section of each game using a text search and manually insuring that the tournaments were correctly sorted. 

Once I had the data, I used several measures to understand the 'solve rate'/difficulty of Jeoaprdy clues. I examined count of wrong guesses per game, correct percentage per game and other attributes across time. I also analyzed the data across several rolling averages since there were over 15 years of game data. When plotting this data on a daily/game basis, there was a significant amount of noise and to analyze larger seasonal trends I ended up using a 90-day rolling average. This was a fairly subjective choice based on what I felt captured trends over many years. 

#### Visualization

I utilized scrollytelling techniques to guide the reader through several of my visualizations. I used ai2html to make the images responsive and some basic D3 to make certain elements change as a reader scrolls through the story.

### Learnings

This was the first time I really utilized scrollytelling to change visualizations or walk readers through a story. It took a lot of back and forth with Illustrator and my front-end HTML (plus a lot of troubleshooting with layering and objects using ai2html). I started to think more about how we can make charts that may have an overwhelming amount of information more approachable using transitions, especially timelines, and 'zooming in' on charts to take a deeper look. 

I think this looks fairly clean, but I would love to create more smooth transitions (probably through D3-based charts rather than Illustrator).