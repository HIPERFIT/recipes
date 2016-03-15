BlackScholesFormula  <- function (spot,timetomat,strike,r, q=0, sigma, opttype=1, greektype=1)
{
 
d1<-(log(spot/strike)+ ((r-q)+0.5*sigma^2)*timetomat)/(sigma*sqrt(timetomat))
d2<-d1-sigma*sqrt(timetomat)
 
if (opttype==1 && greektype==1) result<-spot*exp(-q*timetomat)*pnorm(d1)-strike*exp(-r*timetomat)*pnorm(d2)
 
if (opttype==2 && greektype==1) result<-spot*exp(-q*timetomat)*pnorm(d1)-strike*exp(-r*timetomat)*pnorm(d2)-spot*exp(-q*timetomat)+strike*exp(-r*timetomat)
 
if (opttype==4 && greektype==1) result<-(spot^2)*exp((r+sigma^2)*timetomat)
if (opttype==4 && greektype==2) result<-2*spot*exp((r+sigma^2)*timetomat)
 
if (opttype==1 && greektype==2) result<-exp(-q*timetomat)*pnorm(d1)
 
 
if (opttype==2 && greektype==2) result<-exp(-q*timetomat)*(pnorm(d1)-1)
 
if (greektype==3) result<-exp(-q*timetomat)*dnorm(d1)/(spot*sigma*sqrt(timetomat))
 
if (greektype==4) result<-exp(-q*timetomat)*spot*dnorm(d1)*sqrt(timetomat)
 
BlackScholesFormula<-result
 
}
