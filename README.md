# Google Hacks
A small (very small at the moment) collection of OSINT and security hacks using a Programmable Search Engine and Custom Search API from Google.  Many of these are featured in tutorials or other articles on https://technicalciso.com.

This repo includes:
 1. Flashfinder
 
* For information on Google Programmable Search Engine, see https://developers.google.com/custom-search?hl=en
* For information on Google Custom Search API, see https://developers.google.com/custom-search/v1/overview

---
## Flashfinder
This script uses Google to search for Adobe Flash on a website. Results are individually checked to ensure Flash files still exist and are not from an aging cache.  Flashfinder runs on Linux using the bash shell.  To use Flashfinder, download a copy and run
```
./flashfinder.sh <site>
```
