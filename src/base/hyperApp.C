#include "hyperApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
hyperApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

hyperApp::hyperApp(InputParameters parameters) : MooseApp(parameters)
{
  hyperApp::registerAll(_factory, _action_factory, _syntax);
}

hyperApp::~hyperApp() {}

void
hyperApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAllObjects<hyperApp>(f, af, s);
  Registry::registerObjectsTo(f, {"hyperApp"});
  Registry::registerActionsTo(af, {"hyperApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
hyperApp::registerApps()
{
  registerApp(hyperApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
hyperApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  hyperApp::registerAll(f, af, s);
}
extern "C" void
hyperApp__registerApps()
{
  hyperApp::registerApps();
}
