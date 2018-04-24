[![Build Status](https://travis-ci.org/tseemann/sixess.svg?branch=master)](https://travis-ci.org/tseemann/sixess) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [](#lang-au)

:warning: **THIS SOFTWARE IS STILL UNDER DEVELOPMENT - USE AT OWN RISK**

# sixess
Rapid 16s rDNA from isolate FASTQ files

## Introduction

`sixess` is a command-line software tool to identify 
bacterial species based on 16S rDNA sequence directly
from WGS FASTQ data. It includes databases from 
NCBI (default), RDP and SILVA.

## Quick start

```
# just give it sequences!
% sixess R1.fastq.gz
Staphylococcus epidermidis

# sometimes there is no match
% sixess /dev/null
No matches

# give it as many sequence files as needed
% sixess R1.fq R2.fq
Enterococcus faecium

# we provide different databases you can choose
% sixess -d RDP contigs.fa
Bacillus cereus

# you can pipe to stdin too
% bzcat chernobyl.fq.bz2 | sixess -
Deinococcus radiodurans
```

## Installation

### Source
```
cd $HOME
git clone https://github.com/tseemann/sixess
export PATH=$HOME/sixess/bin:$PATH
```
### Homebrew
```
brew install brewsci/bio/sixess  # COMING SOON
```
### Bioconda
```
conda install -c bioconda -c conda-forge sixess  # COMING SOON
```

## Usage

### Input

The input can be one or more sequence files, or `-` denoting `stdin`.
The input data can be FASTQ or FASTA, and may be `.gz` compressed.
Any read length is accepted, even whole chromosomes.

### Output

The output is a *single line* to `stdout`.
If a match was found, it will be `Genus species`.
If no prediction could be made, it will be `No matches`.

### Options

```
  -q        Quiet mode, no output
  -p DIR    Database folder (/home/tseemann/git/sixess/db)
  -d FILE   Database {NCBI RDP SILVA.gz} (NCBI)
  -t NUM    CPU threads (1)
  -m FILE   Save alignments to FILE in PAF format
  -V        Print version and exit
```

* `-q` enables "quiet mode" which only prints to stderr for errors
* `-p` is the location of the sequence databases
* `-d` selects the database; they can be `.gz` compressed (see [Databases](#databases)
* `-t` increases threads; 3 is the suggested value for `minimap2`
* `-m` allows you to save the PAF output of `minimap2`
* `-V` prints the version and exits *e.g.* `sixess 1.0`

## Databases

### NCBI (bundled, default)

The [NCBI 16S ribosomal RNA project](https://www.ncbi.nlm.nih.gov/refseq/targetedloci/)
contains curated 16S ribosomal RNA bacteria and archaea RefSeq entries.
It has ~20,000 entries.

```
esearch -db nucleotide -query '33175[BioProject] OR 33317[BioProject]' \
  | efetch -db nuccore -format fasta \
  > $(which sixess)/../db/NCBI
```

### RDP (bundled)

Bacterial 16S rDNA sequences for "type strains" 
from the [RDP](https://rdp.cme.msu.edu/) database
are included. These are denoted with `(T)` in the
FASTA headers. It contains ~10,000 entries.

```
wget --no-check-certificate https://rdp.cme.msu.edu/download/current_Bacteria_unaligned.fa.gz
gunzip -c current_Bacteria_unaligned.fa.gz \
  | bioawk -cfastx '/\(T\)/{print ">" $name " " $comment "\n" toupper($seq)}' \
  > $(which sixess)/../db/RDP
```

### SILVA (bundled)

[SILVA](https://www.arb-silva.de/)
is a comprehensive on-line resource for quality checked and 
aligned ribosomal RNA sequence data.
The filtered version of the aligned 16S/18S/SSU database
contains ~100,000 entries.

```
# replace "132" with latest version as needed
wget https://www.arb-silva.de/fileadmin/silva_databases/release_132/Exports/SILVA_132_SSURef_Nr99_tax_silva.fasta.gz
gunzip -v SILVA_132_SSURef_Nr99_tax_silva.fasta.gz \
  | bioawk -cfastx \
    '$comment ~ /^Bacteria;|^Archaea;/ \
    && $comment !~ /(;unidentified|Mitochondria;|;Chloroplast|;uncultured| sp\.)/ \
    { sub(/^.*;/,"",$comment);
      gsub("U","T",$seq);
      print ">" $name " " $comment "\n" $seq }' \
  | seqtk seq -l 60 -U \
  > SILVA.tmp1
cd-hit-est -i SILVA.tmp1 -o SILVA.tmp2 -c 1.0 -T 0 -M 2000 -d 250
cp SILVA.tmp2 $(which sixess)/../db/SILVA
rm -f SILVA.tmp1 SILVA.tmp2 SILVA.tmp2.clstr
```

## Custom databases

Assuming you have a FASTA file of 16S DNA sequences
called `/home/alex/GG.fa` say, you can do this:

### Global installaion

```
cp /home/alex/GG.fa $(which sixess)/../db/GG
sixess -d GG R1.fastq.gz
```

### Local installaion

```
sixess -p /home/alex/data -d GG.fa R1.fastq.gz
```

## Algorithm

1. Identify reads which look like 16S (`minimap2`)
2. Count up how many reads hit each 16S sequence (possibly weighted)
3. Choose the top hit and report it

## Feedback

Report bugs and give suggesions on the
[Issues page](https://github.com/tseemann/sixess/issues)

## License

[GPL Version 3](https://raw.githubusercontent.com/tseemann/sixess/master/LICENSE)

## Author

[Torsten Seemann](http://tseemann.github.io)
