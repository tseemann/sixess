[![Build Status](https://travis-ci.org/tseemann/sixess.svg?branch=master)](https://travis-ci.org/tseemann/sixess) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [](#lang-au)

# sixess
Rapid 16s rDNA from isolate FASTQ files

** WARNING: THIS SOFTWARE IS NOT READY TO USE !!! **

## Introduction

`sixess` is a command-line software tool to identify 
bacterial species based on 16S rDNA sequence directly
from WGS FASTQ data. It includes databases from RDP and NCBI.

## Usage

```
% sixess R1.fastq.gz
<snip>
Staphylococcus epidermidis

% sixess /dev/null
<snip>
No matches

% sixess -d RDP R1.fq.gz R2.fq.gz
Enteroccus faecium

% sixess -d SILVA.gz contigs.fa
Bacillus cereus
```

## Installation

### Source
```
cd $HOME
git clone https://github.com/MDU-PHL/sixess
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

## Database

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
sixess -p /home/alex -d SILVA.fasta R1.fastq.gz
```

## Algorithm

1. Identify reads which look like 16S (`minimap2`)
2. Count up how many reads hit each 16S sequence
3. Choose the top hit and report it

## Feedback

Report bugs and give suggesions on the
[Issues page](https://github.com/tseemann/sixess/issues)

## License

[GPL Version 3](https://raw.githubusercontent.com/tseemann/sixess/master/LICENSE)

## Author

[Torsten Seemann](http://tseemann.github.io)
