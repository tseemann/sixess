# sixess
Rapid 16s rDNA from isolate FASTQ files

##Introduction

`Sixess` is a command-line software tool to identify 
bacterial species based on 16S rDNA sequence directly
from WGS FASTQ data.

**WARNING: This software is not production ready whatsoever!**

##Usage

```sh
% sixess outdir reads.fastq.gz
<snip>
> S000413964 Staphylococcus epidermidis (T); ATCC 14990

% ls outdir
contigs.bls
contigs.fasta  
species.txt

% cat outdir/species.txt
> S000413964 Staphylococcus epidermidis (T); ATCC 14990
Length=1480

 Score = 2661 bits (2950),  Expect = 0.0
 Identities = 1475/1475 (100%), Gaps = 0/1475 (0%)
 Strand=Plus/Minus
```

##Database

Bacterial 16S rDNA sequences for "type strains" 
from the [RDP](https://rdp.cme.msu.edu/) database
are included. These are denoted with `(T)` in the
FASTA headers. It contains ~10,000 entries.

###Adding a database

Assuming you have a FASTA file of 16S DNA sequences
called `/home/alex/SILVA.fasta` say, you can do this:

```sh
cd /path/to/sixess
cd db
mdkir SILVA
cd SILVA
cp /home/alex/SILVA/SILVA.fasta SILVA
makeblastdb -in SILVA -dbtype nucl -title "SILVA" -out SILVA
```

Then run `sixess` and tell it to use that database:

```
sixess -d /path/to/sixess/db/SILVA/SILVA outdir reads.fastq.gz
```

##Algorithm

This method is inspired from the [Ariba](https://github.com/sanger-pathogens/ariba):

1. Identify reads which look like 16S (`minimap`)
2. *De novo* assemble those reads (`megahit`)
3. Choose the longest contig as best candidate
4. Search against the 16S database (`blastn -task blastn`)
5. Report best hit

##Feedback

Report bugs and give suggesions on the
[Issues page](https://github.com/tseemann/sixess/issues)

##License

[GPL Version 3](https://raw.githubusercontent.com/tseemann/sixess/master/LICENSE)

##Authors
* Torsten Seemann

