!********************************************************************************
!   Cassandra - An open source atomistic Monte Carlo software package
!   developed at the University of Notre Dame.
!   http://cassandra.nd.edu
!   Prof. Edward Maginn <ed@nd.edu>
!   Copyright (2013) University of Notre Dame du Lac
!
!   This program is free software: you can redistribute it and/or modify
!   it under the terms of the GNU General Public License as published by
!   the Free Software Foundation, either version 3 of the License, or
!   (at your option) any later version.
!
!   This program is distributed in the hope that it will be useful,
!   but WITHOUT ANY WARRANTY; without even the implied warranty of
!   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!   GNU General Public License for more details.
!
!   You should have received a copy of the GNU General Public License
!   along with this program.  If not, see <http://www.gnu.org/licenses/>.
!*******************************************************************************

SUBROUTINE Accumulate(this_box)

!*******************************************************************************
!
! This subroutine accumulates various thermodynamics properties
!
! Called by
!
! nvtmc_driver
! nptmc_driver
!
! Revision History:
!
! 12/10/13  : Beta Release
!
!********************************************************************************
  USE Global_Variables
  USE Simulation_Properties

  IMPLICIT NONE

  INTEGER :: is, this_box, nmolecules_is
  REAL(DP) :: mass_density

  !--- energy accumulators

  ac_energy(this_box)%total = ac_energy(this_box)%total + energy(this_box)%total
  ac_energy(this_box)%inter_vdw = ac_energy(this_box)%inter_vdw + energy(this_box)%inter_vdw
  ac_energy(this_box)%inter_q   = ac_energy(this_box)%inter_q   + energy(this_box)%inter_q
  ac_energy(this_box)%intra_vdw = ac_energy(this_box)%intra_vdw + energy(this_box)%intra_vdw
  ac_energy(this_box)%intra_q   = ac_energy(this_box)%intra_q   + energy(this_box)%intra_q
  ac_energy(this_box)%intra     = ac_energy(this_box)%intra + energy(this_box)%intra
  ac_energy(this_box)%ewald_reciprocal = ac_energy(this_box)%ewald_reciprocal + energy(this_box)%ewald_reciprocal
  ac_energy(this_box)%self = ac_energy(this_box)%self + energy(this_box)%self

  IF(int_vdw_sum_style(this_box) == vdw_cut_tail) THEN
     ac_energy(this_box)%lrc = ac_energy(this_box)%lrc + energy(this_box)%lrc
  END IF

  !--- virial accumulators

  ac_virial(this_box)%total = ac_virial(this_box)%total + virial(this_box)%total
  ac_virial(this_box)%inter_vdw = ac_virial(this_box)%inter_vdw + virial(this_box)%inter_vdw
  ac_virial(this_box)%inter_q   = ac_virial(this_box)%inter_q + virial(this_box)%inter_q
  ac_virial(this_box)%intra_vdw = ac_virial(this_box)%intra_vdw + virial(this_box)%intra_vdw
  ac_virial(this_box)%intra_q   = ac_virial(this_box)%intra_q + virial(this_box)%intra_q
  ac_virial(this_box)%ewald_reciprocal = ac_virial(this_box)%ewald_reciprocal + virial(this_box)%ewald_reciprocal

  !--- thermodynamic accumulators
  ac_volume(this_box) = ac_volume(this_box) + box_list(this_box)%volume
  IF (need_pressure) THEN
     IF (pressure(this_box)%last_calc /= i_mcstep) THEN
        pressure(this_box)%last_calc = i_mcstep
        CALL Compute_Pressure(this_box)
     END IF
     ac_pressure(this_box) = ac_pressure(this_box) + pressure(this_box)%computed
     ac_enthalpy(this_box) = ac_enthalpy(this_box) &
                           + energy(this_box)%total + pressure(this_box)%computed * box_list(this_box)%volume
  END IF

  !--- particle density
  
  DO is = 1, nspecies
     ac_density(is,this_box) = ac_density(is,this_box) + REAL(nmols(is,this_box),DP) / box_list(this_box)%volume
     ac_nmols(is,this_box) = ac_nmols(is,this_box) + REAL(nmols(is,this_box),DP)
  END DO

  mass_density = 0.0_DP
  DO is = 1, nspecies
     mass_density = mass_density &
                  + REAL(nmols(is,this_box),DP) * species_list(is)%molecular_weight
  END DO
  mass_density = mass_density / box_list(this_box)%volume
  ac_mass_density(this_box) = ac_mass_density(this_box) + mass_density

END SUBROUTINE Accumulate



