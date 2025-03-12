//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

// MOOSE includes
#include "RBEConstraint.h"
#include "MooseMesh.h"

registerMooseObject("MooseApp", RBEConstraint);

InputParameters
RBEConstraint::validParams()
{
  InputParameters params = NodalConstraint::validParams();
  params.addClassDescription(
      "Constrains secondary node to move as a linear combination of primary nodes.");
  params.addRequiredParam<Real>("primary_node_set_id", "The boundary ID associated with the primary nodes.");
  params.addRequiredParam<Real>(
      "secondary_node_set_id", "The boundary ID associated with the secondary side");
  params.addRequiredParam<Real>("penalty", "The penalty used for the boundary term");
  params.addRequiredParam<Real>("primary_size", "The number of nodes in the primary node set");
  // params.addRequiredParam<std::vector<Real>>("weights",
  //                                            "The weights associated with the primary node ids. "
  //                                            "Must be of the same size as primary nodes");
  return params;
}

RBEConstraint::RBEConstraint(const InputParameters & parameters)
  : NodalConstraint(parameters),
    _primary_node_set_id(getParam<Real>("primary_node_set_id")),
    _secondary_node_set_id(getParam<Real>("secondary_node_set_id")),
    _penalty(getParam<Real>("penalty")),
    _primary_size(getParam<Real>("primary_size"))
{

  // if (_primary_node_ids.size() != _weights.size())
    // mooseError("primary and weights should be of equal size.");

  const auto & lm_mesh = _mesh.getMesh();

  // if ((_secondary_node_ids.size() == 0) && (_secondary_node_set_id == "NaN"))
    // mooseError("Please specify secondary_node_ids or secondary_node_set.");


  
  // Get secondary nodes
  std::vector<dof_id_type> nodelist =
      _mesh.getNodeList(_secondary_node_set_id);
  
  for (std::vector<dof_id_type>::iterator in = nodelist.begin(); in != nodelist.end(); ++in)
  {
    const Node * const node = lm_mesh.query_node_ptr(*in);

    if (node && node->processor_id() == _subproblem.processor_id())
    {
        _connected_nodes.push_back(*in); // defining secondary nodes in the base class
    }    
  }


  // Get primary nodes
  std::vector<dof_id_type> primary_nodelist =
      _mesh.getNodeList(_primary_node_set_id);
  
  const auto & node_to_elem_map = _mesh.nodeToElemMap();      
  int node_counter = 0;
  
  for (std::vector<dof_id_type>::iterator in = primary_nodelist.begin(); in != primary_nodelist.end(); ++in)
  {
    //    std::cout << *in << std::endl;
    auto node_to_elem_pair = node_to_elem_map.find(*in);

    // Our mesh may be distributed
    if (node_to_elem_pair == node_to_elem_map.end())
    {
      continue;
    }
        
    // defining primary nodes in base class
    _primary_node_vector.push_back(*in); // defining primary nodes in the base class
    
    const std::vector<dof_id_type> & elems = node_to_elem_pair->second;

    for (const auto & elem_id : elems)
    {
      _subproblem.addGhostedElem(elem_id);
    }
  }
  std::cout << node_counter << std::endl;
  node_counter++;
  _weights = std::vector<Real>(_primary_size, 1.0/_primary_size);
}

Real
RBEConstraint::computeQpResidual(Moose::ConstraintType type)
{
  /**
   * Secondary residual is u_secondary - weights[1]*u_primary[1]-weights[2]*u_primary[2] ...
   *-u_primary[n]*weights[n]
   * However, computeQPresidual is calculated for only a combination of one primary and one
   *secondary node at a time. To get around this, the residual is split up such that the final
   *secondary residual resembles the above expression.
   **/
  unsigned int primary_size = _primary_size;

  switch (type)
  {
    case Moose::Primary:
      return (_u_primary[_j] * _weights[_j] - _u_secondary[_i] / primary_size) * _penalty;
    case Moose::Secondary:
      return (_u_secondary[_i] / primary_size - _u_primary[_j] * _weights[_j]) * _penalty;
  }

  return 0.;
  
}

Real
RBEConstraint::computeQpJacobian(Moose::ConstraintJacobianType type)
{

  unsigned int primary_size = _primary_size;

  switch (type)
  {
    case Moose::PrimaryPrimary:
      return _penalty * _weights[_j];
    case Moose::PrimarySecondary:
      return -_penalty / primary_size;
    case Moose::SecondarySecondary:
      return _penalty / primary_size;
    case Moose::SecondaryPrimary:
      return -_penalty * _weights[_j];
    default:
      mooseError("Unsupported type");
      break;
  }
  return 0.;
}
