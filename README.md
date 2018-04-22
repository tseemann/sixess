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

### NCBI (bundled)

The [NCBI 16S ribosomal RNA project](https://www.ncbi.nlm.nih.gov/refseq/targetedloci/)
contains curated 16S ribosomal RNA sequences
that correspond to bacteria and archaea RefSeq entries.

```
esearch -db nucleotide -query '33175[BioProject] OR 33317[BioProject]' \
  | efetch -db nuccore -format fasta \
  > $(which sixess)/../db/NCBI
```

## Custom databases

Assuming you have a FASTA file of 16S DNA sequences
called `/home/alex/SILVA.fasta` say, you can do this:

### Global installaion

```
cp /home/alex/SILVA.fasta $(which sixess)/../db/SILVA
sixess -d SILVA R1.fastq.gz
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
