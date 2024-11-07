penalty = 1e11

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [meshy]
    type = FileMeshGenerator
    file = '../../mesh/IS_hyp_rbe_no_edges.cpa.gz'
    skip_partitioning = True
  []
[] 
  
[Variables]
  [temperature]
  []
[]
  
[Kernels]
  # Heat conduction kernels
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
    block = '1 2'
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    use_automatic_differentiation = true
    #volumetric_locking_correction = true
    strain = SMALL
    add_variables = true
    #incremental = false
    generate_output = 'vonmises_stress'
  []
[]
  
[UserObjects]
  [heat_flux_csv]
     type = PropertyReadFile
     prop_file_name = ../../HeatFlux/HeatFlux.csv
     read_type = 'voronoi'
     nprop = 4
     nvoronoi = 5682
  []
[]

# Functions to control variable material parameters
[Functions]
  
  [htc_function]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = ../../HeatFlux/HTC.csv
    format = columns
  []  
  #Gaussian Heat profile
  [heat_profile]
    type = PiecewiseConstantFromCSV
    read_type = voronoi
    read_prop_user_object = heat_flux_csv
    column_number = 3
  []

  [./pressure_constant]
    type = ConstantFunction
    value = 0.7e6 # 0.7 MPa
  [../]
  
  [./cucrzr_rho_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/density.csv'
    format = columns
  [../]

  # Copper Youngs modulus
  [./cucrzr_ym_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/youngs_modulus.csv'
    format = columns
  [../]
  
  #Copper Thermal conductivity
  [./cucrzr_tc_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/thermal_conductivity.csv'
    format = columns
  [../]

  #Copper Thermal expansion
  [./cucrzr_te_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/thermal_expansion.csv'
    format = columns
  [../]

  # Copper specific heat
  [./cucrzr_sh_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Copper/specific_heat.csv'
    format = columns
  [../]

  #Nickel youngs modulus
  [./nickel_ym_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Nickel/youngs_modulus.csv'
    format = columns
  [../]
  
  #Nickel thermal conductivity
  [./nickel_tc_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Nickel/thermal_conductivity.csv'
    format = columns
  [../]

  #Nickel thermal expansion
  [nickel_te_fn]
    type = PiecewiseLinear
    scale_factor = 1.0
    axis = x
    data_file = '../../MaterialData/Nickel/thermal_expansion.csv'
    format = columns
  []
[]

  
[Materials]
  [CCZ_elasticity]
    type = ADComputeVariableIsotropicElasticityTensor
    youngs_modulus= 'ccz_ym'
    poissons_ratio = 0.33
    block = 1
  []

  [CCZ_heat]
    type = ADHeatConductionMaterial
    temp = temperature
    specific_heat_temperature_function = cucrzr_sh_fn
    thermal_conductivity_temperature_function = cucrzr_tc_fn
    block = 1
  []

  [CCZ_ym]
    type = ADPiecewiseLinearInterpolationMaterial
    variable = temperature
    property = 'ccz_ym'
    x = '2.000E+01 1.000E+02 1.500E+02 2.000E+02 2.500E+02 3.000E+02 3.500E+02 4.000E+02 4.500E+02 5.000E+02 6.000E+02 7.000E+02'
    y = '1.275E+11 1.270E+11 1.250E+11 1.230E+11 1.210E+11 1.180E+11 1.160E+11 1.130E+11 1.100E+11 1.060E+11 9.500E+10 8.600E+10'
    block = 1
  []

  [CCZ_density]
    type = ADPiecewiseLinearInterpolationMaterial
    variable = temperature
    property = 'density'
    x = '0 50 100 150 200 250 300 350 400 450 500'
    y = '8900 8886 8863 8840 8816 8791 8767 8742 8716 8691 8665'
    
    block = 1
  []

  [CCZ_thermal_expansion]
    type = ComputeMeanThermalExpansionFunctionEigenstrain
    thermal_expansion_function = cucrzr_te_fn
    thermal_expansion_function_reference_temperature = 0.5
    stress_free_temperature = 0.0
    temperature = temperature
    eigenstrain_name = eigenstrain
    block = 1
  []

  [nickel_elasticity]
    type = ADComputeVariableIsotropicElasticityTensor
    youngs_modulus = 'nickel_ym'
    poissons_ratio = 0.31
    block = '2 4'
  []

  [nickel_ym]
    type = ADPiecewiseLinearInterpolationMaterial
    property = 'nickel_ym'
    variable = temperature
    x = '-75 25 100 150 200 300 400 500 600 700'
    y = '2.13E+11 2.07E+11 2.02E+11 1.99E+11 1.97E+11 1.91E+11 1.86E+11 1.8E+11 1.76E+11 1.64E+11'
    block = '2 4'
  []
  
  [nickel_heat]
    type = ADHeatConductionMaterial
    temp = temperature
    specific_heat = 456
    thermal_conductivity_temperature_function = nickel_tc_fn
    block = '2 4'
  []

  [nickel_density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '8885'
    block = '2 4'
  []

  [nickel_thermal_expansion]
    type = ComputeMeanThermalExpansionFunctionEigenstrain
    thermal_expansion_function = nickel_te_fn
    thermal_expansion_function_reference_temperature = 0.5
    stress_free_temperature = 0.0
    temperature = temperature
    eigenstrain_name = eigenstrain
    block = '2'
  []

  [steel]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '7850'
    block = 3
  []

  [steel_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 2e11
    poissons_ratio = 0.3
    block = 3
  []

  [stress]
    type = ADComputeLinearElasticStress
  []
[]

[BCs]
  [heat_flux]
    type = ADFunctionNeumannBC
    variable = temperature
    boundary = 'heat_source'
    function = heat_profile
  []
 
  [heat_removal_backplate]
    type = ADConvectiveHeatFluxBC
    variable = temperature
    boundary = 'heat_flux_backplate'
    heat_transfer_coefficient = 24200
    T_infinity = 295.15
  [../]

  [heat_removal_fins]
    type = ConvectiveFluxFunction
    variable = temperature
    boundary = 'heat_flux_fins'
    coefficient = htc_function
    T_infinity = 295.15
  [../]

  [Pressure]
    [bc]
      boundary = 'pressure'
      function = pressure_constant
      displacements = 'disp_x disp_y disp_z'
    []
  []
[]

[Constraints]
    [rbe3_x_hole]
        type = RBEConstraint
        primary_node_set = 'pin_in_hole_nodeset'
        secondary_node_set = 'pin_in_hole_support'
        variable = disp_x
        primary_size = 209 
        penalty = ${penalty}
    []

    [rbe3_y_hole]
        type = RBEConstraint
        primary_node_set = 'pin_in_hole_nodeset'
        secondary_node_set = 'pin_in_hole_support'
        variable = disp_y
        primary_size = 209
        penalty = ${penalty}
    []

    [rbe3_z_hole]
        type = RBEConstraint
        primary_node_set = 'pin_in_hole_nodeset'
        secondary_node_set = 'pin_in_hole_support'
        variable = disp_z
        primary_size = 209
        penalty = ${penalty}
    []

    [rbe3_x_slot]
        type = RBEConstraint
        primary_node_set = 'pin_in_slot_nodeset'
        secondary_node_set = 'pin_in_slot_support'
        variable = disp_x
        primary_size = 270
        penalty = ${penalty}
    []

    [rbe3_y_slot]
        type = RBEConstraint
        primary_node_set = 'pin_in_slot_nodeset'
        secondary_node_set = 'pin_in_slot_support'
        variable = disp_y
        primary_size = 270
        penalty = ${penalty}
    []

    [rbe3_z_slot]
        type = RBEConstraint
        primary_node_set = 'pin_in_slot_nodeset'
        secondary_node_set = 'pin_in_slot_support'
        variable = disp_z
        primary_size = 270
        penalty = ${penalty}
    []
[]
    
[Executioner]
  type = Steady
  #start_time = 0
  #end_time = 1.5
  #dt = 0.1
  #steady_state_tolerance = 1e-6
  #steady_state_detection = true
  automatic_scaling = true
  compute_scaling_once = false
  solve_type = NEWTON

  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre    boomeramg'
#  petsc_options_iname = '-pc_type'
#  petsc_options_value = 'bjacobi'

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  l_tol = 1e-80
  l_abs_tol = 1e-10
  l_max_its = 400
  line_search = none
[]

[Outputs]
  exodus = true
  perf_graph = true
[]

