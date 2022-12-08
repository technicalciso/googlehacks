# Google Hacks
A small (very small at the moment) collection of OSINT and security hacks using a Programmable Search Engine and Custom Search API from Google.  The scripts lack significant error checking, commercial or enterprise features, and are mostly just proofs of concept. Many of these are featured in tutorials or other articles on https://technicalciso.com.

> * For info on Google Programmable Search Engine, see https://developers.google.com/custom-search?hl=en
> * For info on Google Custom Search API, see https://developers.google.com/custom-search/v1/overview


This repo includes:
 1. Flashfinder
 2. Neganews
 
 ---
## Flashfinder
This script uses Google to search for Adobe Flash on a website. Results are individually checked to ensure Flash files still exist and are not from an aging cache.  Flashfinder runs on Linux using the bash shell.  To use Flashfinder, download a copy and run
```
./flashfinder.sh <site>
```
## Neganews
This script uses Google to search for adverse (negative) news about a company or group of companies.  For each company, a Google search is conducted together with any of the keywords defined, such as _breach_ or _DDOS_. To use Neganews, create a file with company names, a file with keywords to search for. Download a copy and run
```
./neganews.sh -c <companynames_file> -k <keywords_file> [-m max_results] [-l logfile]
```
The gconfig variable in the script can be edited to change search behavior. The default is set to Google news items only, published within the last two days, and sorted by date. There are a number of limitations to the script, listed in the script comments at the top.
