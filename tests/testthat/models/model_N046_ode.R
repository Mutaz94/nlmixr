source("helper-prep_fit.R")
context("NLME46: two-compartment infusion, single-dose")
runno <- "N046_ode"

datr <-
  read.csv("../Infusion_2CPT.csv",
           header = TRUE,
           stringsAsFactors = F)
datr$EVID <- ifelse(datr$EVID == 1, 10101, datr$EVID)

datr <- datr[datr$EVID != 2,]

datIV <- datr[datr$AMT > 0,]
datIV$TIME <- datIV$TIME + (datIV$AMT/datIV$RATE)
datIV$AMT  <- -1*datIV$AMT

datr <- rbind(datr, datIV)
datr <- datr[order(datr$ID, datr$TIME),]

ode2 <- "
d/dt(centr)  = K21*periph-K12*centr-K10*centr;
d/dt(periph) =-K21*periph+K12*centr;
"

specs6 <-
  list(
    fixed = lCL + lV + lCLD + lVT ~ 1,
    random = pdDiag(lCL + lV + lCLD + lVT ~ 1),
    start = c(
      lCL = 1.6,
      lV = 4.5,
      lCLD = 1.5,
      lVT = 3.9
    )
  )

mypar6 <- function(lCL, lV, lCLD, lVT)
{
  CL <- exp(lCL)
  V  <- exp(lV)
  CLD <- exp(lCLD)
  VT <- exp(lVT)
  K10 <- CL / V
  K12 <- CLD / V
  K21 <- CLD / VT
}

dat <- datr[datr$SD == 1,]

fit[[runno]] <-
  nlme_ode(
    dat,
    model = ode2,
    par_model = specs6,
    par_trans = mypar6,
    response = "centr",
    response.scaler = "V",
    weight = varPower(fixed = c(1)),
    verbose = verbose_minimization,
    control = default_control
  )

# Generate this with generate_expected_values(fit[[runno]])
expected_values[[runno]] <-
  list(
    lik=c(-11943.93, 23905.85, 23957.44),
    param=c(1.3861, 4.2173, 1.3686, 3.8961),
    stdev_param=c(1.5049, 1.5268, 1.2185, 1.3989),
    sigma=c(0.19859)
  )
