source("helper-prep_fit.R")
context("NLME32: two-compartment bolus, single-dose")
runno <- "N032"

datr <- Bolus_2CPT

datr$EVID <- ifelse(datr$EVID == 1, 101, datr$EVID)
datr <- datr[datr$EVID != 2,]

specs6 <-
  list(
    fixed = lCL + lV + lCLD + lVT ~ 1,
    random = pdDiag(lCL + lV + lCLD + lVT ~ 1),
    start = c(
      lCL = 1.37,
      lV = 4.19,
      lCLD = 1.37,
      lVT = 3.87
    )
  )

dat <- datr[datr$SD == 1,]

fit[[runno]] <-
  nlme_lin_cmpt(
    dat,
    par_model = specs6,
    ncmt = 2,
    oral = FALSE,
    weight = varPower(fixed = c(1)),
    verbose = verbose_minimization,
    control = default_control
  )

# Generate this with generate_expected_values(fit[[runno]])
expected_values[[runno]] <-
  list(
    lik=c(-12178.04, 24374.08, 24425.67),
    param=c(1.3703, 4.1826, 1.4346, 3.8741),
    stdev_param=c(1.5903, 1.5809, 1.5398, 1.2407),
    sigma=c(0.19838)
  )
