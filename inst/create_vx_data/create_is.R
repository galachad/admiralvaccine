library(labelled)

table <- matrix(NA, nrow = 16, ncol = 28)

colnames(table) <- c(
  "STUDYID", "DOMAIN", "USUBJID", "ISSEQ", "ISGRPID", "ISREFID", "ISSPID", "ISLNKID",
  "ISTESTCD", "ISTEST", "ISCAT", "ISORRES", "ISORRESU", "ISSTRESC", "ISSTRESN",
  "ISSTRESU", "ISSTAT", "ISREASND", "ISNAM", "ISSPEC", "ISMETHOD", "ISBLFL", "ISLLOQ",
  "VISITNUM", "EPOCH", "ISDTC", "ISDY", "ISULOQ"
)

table1 <- as.data.frame(table)

for (i in 1:NROW(table1)) {
  table1[i, 1] <- as.character("ABC")
  table1[i, 2] <- as.character("IS")
  table1[i, 5] <- as.character("XX")
  table1[i, 11] <- as.character("IMMUNOLOGY")
  table1[i, 13] <- as.character("1/DIL")
  table1[i, 19] <- as.character("LABNAME")
  table1[i, 20] <- as.character("SERUM")
  table1[i, 21] <- as.character("METHODNAME")
}


table1$ISTESTCD <- rep(c("J0033VN", "I0019NT", "M0019LN", "R0003MA"), 4)

table1$USUBJID <- c(
  rep("ABC-1001", 8), rep("ABC-1002", 8)
)

table1$VISITNUM <- c(
  rep(10, 4), rep(30, 4), rep(10, 4), rep(30, 4)
)

set.seed(1234)
table1$ISORRES <- sample(c("2", "3", "5", "<2", ">8"), NROW(table1), replace = T)

is1 <- table1 %>%
  group_by(STUDYID, USUBJID) %>%
  mutate(ISSEQ = row_number()) %>%
  ungroup() %>%
  mutate(
    EPOCH = if_else(VISITNUM == 10, "FIRST TREATMENT", "SECOND TREATMENT"),
    ISDTC = if_else(VISITNUM == 10, "2015-01-10", "2015-03-10"),
    ISDY = if_else(VISITNUM == 10, "1", "61"),
    ISBLFL = if_else(VISITNUM == 10, "Y", NA_character_),
    ISSTRESU = "titer",
    ISTEST = case_when(
      ISTESTCD == "J0033VN" ~ "J0033VN Antibody",
      ISTESTCD == "I0019NT" ~ "I0019NT Antibody",
      ISTESTCD == "M0019LN" ~ "M0019LN Antibody",
      ISTESTCD == "R0003MA" ~ "R0003MA Antibody"
    ),
    ISLLOQ = case_when(
      ISTESTCD == "J0033VN" ~ 2,
      ISTESTCD == "I0019NT" ~ 4,
      ISTESTCD == "M0019LN" ~ 8,
      ISTESTCD == "R0003MA" ~ 4
    ),
    ISULOQ = case_when(
      ISTESTCD == "J0033VN" ~ 100,
      ISTESTCD == "I0019NT" ~ 200,
      ISTESTCD == "M0019LN" ~ 150,
      ISTESTCD == "R0003MA" ~ 120
    ),
    ISSTRESC = case_when(
      ISORRES == "2" ~ "2",
      ISORRES == "3" ~ "3",
      ISORRES == "5" ~ "5",
      ISORRES == "<2" ~ NA_character_,
      ISORRES == ">8" ~ NA_character_
    ),
    ISSTRESN = case_when(
      ISORRES == "2" ~ 2,
      ISORRES == "3" ~ 3,
      ISORRES == "5" ~ 5,
      ISORRES == "<2" ~ NA_real_,
      ISORRES == ">8" ~ NA_real_
    )
  ) %>%
  group_by(STUDYID, USUBJID, VISITNUM) %>%
  mutate(ISREFID = 100000 + as.numeric(substr(USUBJID, 8, 14))) %>%
  ungroup() %>%
  mutate(LOD = case_when(
    ISTESTCD == "J0033VN" ~ 2,
    ISTESTCD == "I0019NT" ~ 2,
    ISTESTCD == "M0019LN" ~ 2,
    ISTESTCD == "R0003MA" ~ 2
  ))

# To add NOT DONE records
is <- is1 %>%
  mutate(
    ISORRES = if_else(row_number() == 1 | row_number() == 10, NA_character_, ISORRES),
    ISSTRESC = if_else(row_number() == 1 | row_number() == 10, NA_character_, ISSTRESC),
    ISSTRESN = if_else(row_number() == 1 | row_number() == 10, NA_real_, ISSTRESN),
    ISSTRESU = if_else(row_number() == 1 | row_number() == 10, NA_character_, ISSTRESU),
    ISORRESU = if_else(row_number() == 1 | row_number() == 10, NA_character_, ISORRESU),
    ISSTAT = if_else(row_number() == 1 | row_number() == 10, "NOT DONE", NA_character_),
    ISREASND = if_else(row_number() == 1 | row_number() == 10, "INVALID RESULT", NA_character_),
    # Add missing dates
    ISDTC = case_when(
      row_number() == 1 ~ NA_character_,
      row_number() == 2 ~ "2021-11",
      row_number() == 3 ~ "2021-11",
      row_number() == 4 ~ "2021-11",
      row_number() == 5 ~ "2021-12",
      row_number() == 6 ~ "2021-12",
      row_number() == 7 ~ "2021-12",
      row_number() == 8 ~ "2021-12",
      row_number() == 9 ~ "2021",
      row_number() == 10 ~ NA_character_,
      row_number() == 11 ~ "2021",
      row_number() == 12 ~ "2021",
      row_number() == 13 ~ "2021",
      row_number() == 14 ~ "2021",
      row_number() == 15 ~ "2021",
      row_number() == 16 ~ "2021",
      TRUE ~ ISDTC
    ),
    # Add higher ISSTRESN values
    ISORRES = case_when(
      row_number() == 4 ~ "140.5",
      row_number() == 8 ~ "98.2",
      row_number() == 12 ~ "48.9",
      row_number() == 16 ~ "228.1",
      TRUE ~ as.character(ISORRES)
    ),
    ISSTRESC = case_when(
      row_number() == 4 ~ "140.5",
      row_number() == 8 ~ "98.2",
      row_number() == 12 ~ "48.9",
      row_number() == 16 ~ "228.1",
      TRUE ~ as.character(ISSTRESC)
    ),
    ISSTRESN = case_when(
      row_number() == 4 ~ 140.5,
      row_number() == 8 ~ 98.2,
      row_number() == 12 ~ 48.9,
      row_number() == 16 ~ 228.1,
      TRUE ~ as.numeric(ISSTRESN)
    ),
    ISORRES = case_when(
      ISORRES == ">8" & ISTESTCD == "J0033VN" ~ ">100",
      ISORRES == ">8" & ISTESTCD == "I0019NT" ~ ">200",
      ISORRES == ">8" & ISTESTCD == "M0019LN" ~ ">150",
      ISORRES == ">8" & ISTESTCD == "R0003MA" ~ ">120",
      TRUE ~ ISORRES
    ),
    ISSTRESC = ISORRES,
    ISDY = case_when(
      row_number() == 1 ~ NA_character_,
      row_number() == 10 ~ NA_character_,
      TRUE ~ ISDY
    )
  )


var_label(is$STUDYID) <- "Study Identifier"
var_label(is$DOMAIN) <- "Domain Abbreviation"
var_label(is$USUBJID) <- "Unique Subject Identifier"
var_label(is$ISSEQ) <- "Sequence Number"
var_label(is$ISGRPID) <- "Group ID"
var_label(is$ISREFID) <- "Reference ID"
var_label(is$ISSPID) <- "Sponsor-Defined Identifier"
var_label(is$ISLNKID) <- "Link ID"
var_label(is$ISTESTCD) <- "Immunogenicity Test/Exam Short Name"
var_label(is$ISTEST) <- "Immunogenicity Test or Examination Name"
var_label(is$ISCAT) <- "Category for Immunogenicity Test"
var_label(is$ISORRES) <- "Results or Findings in Original Units"
var_label(is$ISORRESU) <- "Original Units"
var_label(is$ISSTRESC) <- "Character Result/Finding in Std Format"
var_label(is$ISSTRESN) <- "Numeric Results/Findings in Std. Units"
var_label(is$ISSTRESU) <- "Standard Units"
var_label(is$ISSTAT) <- "Completion Status"
var_label(is$ISREASND) <- "Reason Not Done"
var_label(is$ISNAM) <- "Vendor Name"
var_label(is$ISSPEC) <- "Specimen Type"
var_label(is$ISMETHOD) <- "Method of Test or Examination"
var_label(is$ISBLFL) <- "Baseline Flag"
var_label(is$ISLLOQ) <- "Lower Limit of Quantitation"
var_label(is$VISITNUM) <- "Visit Number"
var_label(is$EPOCH) <- "Epoch"
var_label(is$ISDTC) <- "Date/Time of Collection"
var_label(is$ISDY) <- "Study Day of Visit/Collection/Exam"
var_label(is$LOD) <- "Limit of Detection"
var_label(is$ISULOQ) <- "Upper Limit of Quantitation"


vx_is <- is %>%
  select(-c(ISGRPID, ISREFID, ISSPID, ISLNKID, LOD))
